class FightLogic < DNDLogic
  class<<self
    def fight_to_json fight, is_master
      render = is_master || fight.fase>0 #==2
      {
        fighters: render ?
          fight.get_fighters(is_master).sort_by{|x|x[:step_order]} :
          [],
        fight: {
          fase: fight.fase,
          step: fight.current_step,
          fighter_index: fight.fighter_index,
          render: render
        }
      }.to_json
    end

    def send_fight ws, fight, is_master
      ws.send fight_to_json(fight, is_master)
    end
    
    def update_fight_for_all fight
      send_all (fight_to_json(fight, false).to_s) {|p| !p.is_master}
      send_all (fight_to_json(fight, true).to_s) {|p| p.is_master}
    end

    def new_fight player
      fight = Fight.make_fight(adventure: player.adventure, add_players: true)
      send_fight ws, fight, player.is_master
    end

    def update_npc n, fight
      #logger.warn "fighter #{$1} hp=#{$2}"
      npc = NonPlayer.find_by_id(n)
      if npc and npc.fight.id==fight.id
        yield npc
        npc.save
        send_fight ws, fight, player.is_master
      else
        logger.warn "npc=#{npc}"
        logger.warn "#{npc.fight.id}==#{fight.id}" if npc
      end      
    end

    def process_message ws,user,player,text,opts={}
      logger.warn "Fight logic (#{text})"
      fight = get_fight player
      is_master = player.is_master
      
      new_fight if fight.nil?
      if fight.adventure != player.adventure
        logger.warn "Not correct adventure."
        return
      end
      begin
        case text
        when 'get_fight'
          logger.warn "get_fight"
          send_fight ws, fight, player.is_master
        when /^dice_rolled (\d+)/
          c = player.get_char(:initiative)
          logger.warn "c=#{c}"
          player.real_initiative = c.to_i+$1.to_i
          player.save
          fight.update_step_orders
          #send_player ws, player, true
          update_fight_for_all fight
        else
          if is_master
            case text
            when /^new-npc (\d+) (\d+)/
              type_id = $1.to_i
              num = $2.to_i
              logger.warn "new-npc (#{type_id} #{num})"
              r = NpcType.find_by_id(type_id)
              if r.nil?
                logger.warn "No such NPC"
              else
                while num>0 do
                  num -= 1
                  npc = NonPlayer.generate(r, fight)
                  if npc.save
                    fight.update_step_orders
                    logger.warn "ok!"
                  else
                    loger.warn "oooops... #{npc.errors.join(';')}"
                  end
                end
                send_fight ws, fight, player.is_master
              end

            when /^fighter-del (\d+) (\S+)/
              logger.warn "del fighter npc=#{$2}"
              if $2 == 'true' # NPC
                npc = NonPlayer.find_by_id($1)
                if npc and npc.fight == fight
                  npc.delete
                  fight.update_step_orders
                  send_fight ws, fight, player.is_master
                end
              else # Player
                pl = Player.find_by_id($1)
                if pl
                  pl.is_fighter = false
                  pl.save
                  fight.update_step_orders
                  send_fight ws, fight, player.is_master
                end
              end

            when /^fighter-restore (\d+)/
              logger.warn "restore fighter #{$1}"
              pl = Player.find_by_id($1)
              if pl
                pl.is_fighter = true
                pl.save
                fight.update_step_orders
                send_fight ws, fight, player.is_master
              end

            when 'next'
              logger.warn "next fighter"
              list = fight.get_fighters(is_master).sort_by{|x|x[:step_order]}
              i = fight.fighter_index
              flag = false
              loop do
                i += 1
                if i>=list.size
                  i = 0
                  fight.current_step += 1
                  if flag
                    logger.warn "A!!!!!!!!!! infinite loop detected!"
                    raise "infinite loop"
                  else
                    flag = true
                  end
                end
                logger.warn "---> #{i}: #{list[i].inspect}"
                break if list[i][:is_fighter]
              end
              fight.fighter_index = i
              fight.save
              update_fight_for_all fight
              if !list[i][:is_npc]
                send_to_player(list[i][:id],{event: 'Your move!'}.to_json)
              end

            when 'del'
              fight.finish
              ws.send({fighters: []}.to_json)

            when 'new'
              logger.warn "New fight (#{player.is_master} / #{fight})"

              fight.delete
              new_fight player
              send_fight ws, get_fight(player), player.is_master

            when 'start'
              logger.warn "Start fight! Do roll initiative"
              case fight.fase
              when 0
                fight.fase = 1
                fight.fighter_index = 0
                fight.save
                send_fight ws, fight, player.is_master
                DNDLogic.send_all({event: 'roll-initiative'}) do |p|
                  ! p.is_master
                end
              when 1
                fight.fase = 2
                fight.fighter_index = 0
                fight.save
                send_fight ws, fight, player.is_master
                DNDLogic.send_all({event: 'start-fight'})
              when 2
                fight.fase = 3
                fight.save
                send_fight ws, fight, player.is_master
                DNDLogic.send_all({event: 'start-fight'})                
              end
            when /^initiative (\d+)=(-?\d+)/
              logger.warn "fighter #{$1} initiative=#{$2}"
              pl = Player.find_by_id($1)
              if pl.adventure != fight.adventure
                logger.warn "Oops! It is not our player!!"
              else
                pl.real_initiative = $2.to_i
                pl.save
                fight.update_step_orders
                send_fight ws, fight, player.is_master
              end

            when /^hp (\d+)=(-?\d+)/
              logger.warn "fighter #{$1} hp=#{$2}"
              update_npc($1, fight) {|npc|
                npc.hp = $2.to_i
              }
 
            when /^max_hp (\d+)=(-?\d+)/
              logger.warn "fighter #{$1} max_hp=#{$2}"
              update_npc($1, fight) {|npc|
                npc.max_hp = $2.to_i
                # npc.save
                # send_fight ws, fight, player.is_master
              }
 
            when /^ac (\d+)=(-?\d+)/
              logger.warn "fighter #{$1} ac=#{$2}"
              update_npc($1, fight) {|npc|
                npc.armor_class = $2.to_i
                # npc.save
                # send_fight ws, fight, player.is_master
              }

            # change fighter step priority
            when /^step (\d+) (\S+) (\+|-)/
              logger.warn "fighter-step #{$1} #{$2} #{$3} (master=#{player.is_master}, afight=#{player.adventure.active_fight}, rfight=#{player.adventure.ready_fight}"
              is_npc = $2=='true'
              list = fight.get_fighters(player.is_master).sort_by{|x|x[:step_order]}
              # logger.warn "... #{list.inspect}"
              index = list.index{|x| x[:is_npc]==is_npc and x[:id]==$1.to_i}
              if index
                f0 = get_fighter list[index]
                f1 = nil
                if $3=='+' and index>0
                  f0[:step_order] -= 1
                  f1 = get_fighter list[index-1]
                  f1[:step_order] += 1
                elsif $3=='-' and index<list.size
                  f0[:step_order]+=1
                  f1 = get_fighter list[index+1]
                  f1[:step_order] -= 1
                else
                  warn "Ooooops! Bad fighter index!"
                  return
                end
                f1.save
                f0.save
                f = get_fight player
                send_fight ws, fight, player.is_master
              else
                warn "Oooops! no such fighter!"
              end
            else
              logger.warn "Incorrect command '#{text}'. Ignore."
            end # case
          else # ! master
          end
        end # case
      rescue => e
        logger.warn "BAD message, got error: #{e.message} (#{e.backtrace.join("\n")})"
      end
    end
  end
end
