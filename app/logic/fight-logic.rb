class FightLogic < DNDLogic
  class<<self
    def process_message ws,user,player,text,opts={}
      logger.warn "Fight logic (#{text})"
      fight = get_fight player
      begin
        case text
        when /new-npc (\d+)/
          race_id = $1.to_i
          logger.warn "new-npc (#{race_id})"
          r = Race.find_by_id(race_id)
          # logger.warn "master-#{player.is_master} race-#{!r.nil?} fight-#{!f.nil?}"
          # logger.warn "fa=#{f.adventure} pa=#{player.adventure}"
          return if !player.is_master or r.nil? or fight.nil? or fight.adventure != player.adventure
          npc = NonPlayer.generate(r, fight)
          if npc.save
            fight.update_step_orders
            #players = player.adventure.players.where(is_master: false).select(:name,:race,:hp,:max_hp,:initiative)
            ws.send({fighters: fight.get_fighters(true).sort_by{|x|x[:step_order]}}.to_json)
            logger.warn "ok!"
          else
            loger.warn "oooops... #{npc.errors.join(';')}"
          end

        when /fighter-del (\d+) (\S+)/
          logger.warn "del fighter npc=#{$2}"
          return if !player.is_master or fight.nil?
          if $2 == 'true' # NPC
            npc = NonPlayer.find_by_id($1)
            if npc and npc.fight == fight
              npc.delete
              fight.update_step_orders
              ws.send({fighters: fight.get_fighters(true).sort_by{|x|x[:step_order]}}.to_json)
            end
          else # Player
            pl = Player.find_by_id($1)
            if pl
              pl.is_fighter = false
              pl.save
              fight.update_step_orders
              ws.send({fighters: fight.get_fighters(true).sort_by{|x|x[:step_order]}}.to_json)
            end
          end

        when /fighter-restore (\d+)/
          logger.warn "restore fighter #{$1}"
          return if !player.is_master or fight.nil?
          pl = Player.find_by_id($1)
          if pl
            pl.is_fighter = true
            pl.save
            fight.update_step_orders
            ws.send({fighters: fight.get_fighters(true).sort_by{|x|x[:step_order]}}.to_json)
          end

        when 'del'
          if fight
            fight.finish
          end
          ws.send({fighters: []}.to_json)

        when 'new'
          logger.warn "New fight (#{player.is_master} / #{fight})"
          return if !player.is_master

          #fight = player.adventure.active_fight || player.adventure.ready_fight
          if !fight
            fight = Fight.make_fight(adventure: player.adventure, add_players: true)
          end
          ws.send({fighters: fight.get_fighters(player.is_master).sort_by{|x|x[:step_order]}}.to_json)

        when /hp (\d+)=(-?\d+)/
          logger.warn "fighter #{$1} hp=#{$2}"
          return if fight.nil?
          npc = NonPlayer.find_by_id($1)
          if npc and npc.fight.id==fight.id
            npc.hp = $2.to_i
            npc.save
            ws.send({fighters: fight.get_fighters(player.is_master).sort_by{|x|x[:step_order]}}.to_json)
          else
            logger.warn "npc=#{npc}"
            logger.warn "#{npc.fight.id}==#{fight.id}" if npc
          end

        when /max_hp (\d+)=(-?\d+)/
          logger.warn "fighter #{$1} max_hp=#{$2}"
          return if fight.nil?
          npc = NonPlayer.find_by_id($1)
          if npc and npc.fight.id==fight.id
            npc.max_hp = $2.to_i
            npc.save
            ws.send({fighters: fight.get_fighters(player.is_master).sort_by{|x|x[:step_order]}}.to_json)
          else
            logger.warn "npc=#{npc}"
            logger.warn "#{npc.fight.id}==#{fight.id}" if npc
          end

        when /ac (\d+)=(-?\d+)/
          logger.warn "fighter #{$1} ac=#{$2}"
          return if fight.nil?
          npc = NonPlayer.find_by_id($1)
          if npc and npc.fight.id==fight.id
            npc.armor_class = $2.to_i
            npc.save
            ws.send({fighters: fight.get_fighters(player.is_master).sort_by{|x|x[:step_order]}}.to_json)
          else
            logger.warn "npc=#{npc}"
            logger.warn "#{npc.fight.id}==#{fight.id}" if npc
          end

        # change fighter step priority
        when /step (\d+) (\S+) (\+|-)/
          logger.warn "fighter-step #{$1} #{$2} #{$3} (master=#{player.is_master}, afight=#{player.adventure.active_fight}, rfight=#{player.adventure.ready_fight}"
          is_npc = $2=='true'
          return if fight.nil?
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
            # logger.warn "f0=#{f0.inspect}"
            # logger.warn "f1=#{f1.inspect}"
            f = get_fight player
            #f.update_step_orders
            ws.send({fighters: fight.get_fighters(true).sort_by{|x|x[:step_order]}}.to_json)
          else
            warn "Oooops! no such fighter!"
          end

        when 'get_fight'
          logger.warn "get_fight"
          return if fight.nil?
          ws.send({fighters: fight.get_fighters(player.is_master).sort_by{|x|x[:step_order]}}.to_json)
        else
          logger.warn "Incorrect command '#{text}'. Ignore."
        end
      rescue => e
        logger.warn "BAD message, got error: #{e.message} (#{e.backtrace.join("\n")})"
      end
    end
  end
end
