# frozen_string_literal: true

#
# Fight logic
#
# @author [serg]
#
class FightLogic < DNDLogic
  class<<self
    def fight_to_json(fight, is_master)
      render = is_master || fight.fase.positive?
      {
        fighters: if render
                    fight.get_fighters(is_master).sort_by(&:step_order)
                  else
                    []
                  end,
        fight: {
          fase: fight.fase,
          step: fight.current_step,
          fighter_index: fight.fighter_index,
          render: render
        }
      }.to_json
    end

    def groups_to_json(adventure)
      groups = adventure.fight_groups.order(:id).map do |grp|
        {
          name: grp.name,
          id: grp.id,
          npc: grp.non_players.sort_by(&:step_order).map(&:to_hash)
        }
      end
      { groups: groups }.to_json
    end

    def send_fight(ws, fight, is_master)
      ws.send fight_to_json(fight, is_master)
    end

    def send_groups(ws, adventure)
      ws.send groups_to_json(adventure)
    end

    def update_fight_for_all(fight)
      send_all(fight_to_json(fight, false).to_s) { |p| !p.is_master }
      send_all(fight_to_json(fight, true).to_s) { |p| p.is_master }
    end

    def new_fight player
      logger.warn 'NEW FIGHT...'
      fight = get_fight player
      if fight
        logger.warn "deleted old fight #{fight.id}"
        fight.delete
      end
      f = Fight.make_fight(adventure: player.adventure, add_players: true)
      logger.warn "New fight #{f.id}"
      # send_fight ws, fight, player.is_master
    end

    def update_npc(ws, n, fight, all=false)
      # logger.warn "fighter #{$1} hp=#{$2}"
      npc = NonPlayer.find_by_id(n)
      if npc && npc.fight.id == fight.id
        yield npc
        npc.save
        send_fight ws, fight, true
        send_all(fight_to_json(fight, false)) { |p| !p.is_master } if all
      else
        logger.warn "npc=#{npc}"
        logger.warn "#{npc.fight.id}==#{fight.id}" if npc
      end
    end

    def update_npc_grp(ws, n, adventure)
      npc = NonPlayer.find_by_id(n)
      if npc
        yield npc
        npc.save
        logger.warn "npc updated: #{npc.inspect}"
        send_groups ws, adventure
      else
        logger.warn "update_npc_grp falied for npc=#{npc}"
      end
    end

    def process_message(ws, user, player, text, opts={})
      logger.warn "Fight logic (#{text})"
      fight = get_fight player
      is_master = player.is_master

      fight = new_fight(player) if fight.nil?
      if fight.adventure != player.adventure
        logger.warn 'Not correct adventure.'
        return
      end
      begin
        case text
        when 'get_fight'
          logger.warn 'get_fight'
          send_fight ws, fight, player.is_master
        when /^dice_rolled (\d+)/
          c = player.get_char(:initiative)
          logger.warn "c=#{c}"
          player.real_initiative = c.to_i + $LAST_MATCH_INFO[1].to_i
          player.save
          fight.update_step_orders
          # send_player ws, player, true
          update_fight_for_all fight
        else
          if is_master
            case text
            when /^new-npc (\d+) (\d+)/
              type_id = $LAST_MATCH_INFO[1].to_i
              num = $LAST_MATCH_INFO[2].to_i
              logger.warn "new-npc (#{type_id} #{num})"
              r = NpcType.find_by_id(type_id)
              if r.nil?
                logger.warn 'No such NPC'
              else
                while num.positive?
                  num -= 1
                  npc = NonPlayer.generate(r, fight)
                  if npc
                    fight.update_step_orders
                    logger.warn 'ok!'
                  else
                    loger.warn "oooops... #{npc.errors.join(';')}"
                  end
                end
                if fight.fase == 2 # fight in progress
                  send_all(fight_to_json(fight, false)) do |p|
                    !p.is_master
                  end
                end
                send_fight ws, fight, player.is_master
              end

            # num, hp, max_hp, armor, initiative, name
            when /^new-tmp-npc (\d+) (\d+) (\d+) (\d+) (\d+) (.+)/
              num = $LAST_MATCH_INFO[5].to_i
              logger.warn "new-tmp-npc (#{$LAST_MATCH_INFO[6]} #{num})"
              r = NpcType.find_or_create_by!(
                name: $LAST_MATCH_INFO[6],
                is_tmp: true
              )
              if r.nil?
                logger.warn 'Cannot create such NPC'
                ws.send({ flash: t('cannot_create_npc') }.to_json)
              else
                hp            = $LAST_MATCH_INFO[1].to_i
                r.max_hp      = $LAST_MATCH_INFO[2].to_i
                r.armor_class = $LAST_MATCH_INFO[3].to_i
                r.initiative  = $LAST_MATCH_INFO[4].to_i
                r.save
                while num.positive?
                  num -= 1
                  npc = NonPlayer.generate(r, fight)
                  npc.hp = hp
                  if npc
                    fight.update_step_orders
                    logger.warn 'ok!'
                  else
                    loger.warn "oooops... #{npc.errors.join(';')}"
                  end
                end
                if fight.fase == 2 # fight in progress
                  send_all(fight_to_json(fight, false)) do |p|
                    !p.is_master
                  end
                end
                send_fight ws, fight, player.is_master
              end

            when /^fighter-del (\d+) (\S+)/
              logger.warn "del fighter npc=#{$LAST_MATCH_INFO[2]}"
              if $LAST_MATCH_INFO[2] == 'true' # NPC
                npc = NonPlayer.find_by_id($LAST_MATCH_INFO[1])
                if npc && npc.fight == fight
                  npc.delete
                  fight.update_step_orders
                  send_fight ws, fight, player.is_master
                end
              else # Player
                pl = Player.find_by_id($LAST_MATCH_INFO[1])
                if pl
                  pl.is_fighter = false
                  pl.save
                  fight.update_step_orders
                  send_fight ws, fight, player.is_master
                end
              end

            when /^fighter-restore (\d+)/
              logger.warn "restore fighter #{$LAST_MATCH_INFO[1]}"
              pl = Player.find_by_id($LAST_MATCH_INFO[1])
              if pl
                pl.is_fighter = true
                pl.save
                fight.update_step_orders
                send_fight ws, fight, player.is_master
              end

            when 'next'
              logger.warn 'next fighter'
              list = fight.get_fighters(is_master).sort_by(&:step_order)
              i = fight.fighter_index
              flag = false
              loop do
                i += 1
                if i >= list.size
                  i = 0
                  fight.current_step += 1
                  if flag
                    logger.warn 'A!!!!!!!!!! infinite loop detected!'
                    raise 'infinite loop'
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
                send_to_player(list[i][:id], { event: 'Your move!' }.to_json)
              end

            when 'del'
              fight.finish
              ws.send({ fighters: [] }.to_json)

            when 'new'
              logger.warn "New fight (#{player.is_master} / #{fight})"

              fight.delete
              new_fight player
              send_fight ws, get_fight(player), player.is_master

            when 'next-fase'
              logger.warn "Fight fase=#{fight.fase}. Do next!"
              case fight.fase
              when 0 # just prepared
                fight.fase = 1
                fight.fighter_index = 0
                fight.save
                logger.warn "Do roll initiative!"
                send_fight ws, fight, true
                send_all(fight_to_json(fight, false)) do |p|
                  !p.is_master
                end
                send_all({ event: 'roll-initiative' }) do |p|
                  !p.is_master
                end
              when 1 # initiative rolled
                fight.fase = 2
                fight.fighter_index = 0
                fight.save
                logger.warn 'Start fight!'
                # send_fight ws, fight, player.is_master
                send_all(fight_to_json(fight, is_master))
                send_all({ event: 'start-fight' })
              when 2 # fight...
                fight.fase = 3
                fight.save
                logger.warn 'Stop fight!'
                # send_fight ws, fight, player.is_master
                send_all(fight_to_json(fight, is_master))
                send_all({ event: 'stop-fight' })
              when 3 # finished...
                fight.delete
                logger.warn 'New fight!'
                new_fight player
                send_fight ws, get_fight(player), player.is_master
              end
            when /^initiative (\d+)=(-?\d+)/
              logger.warn "fighter #{$LAST_MATCH_INFO[1]} initiative=#{$LAST_MATCH_INFO[2]}"
              pl = Player.find_by_id($LAST_MATCH_INFO[1])
              if pl.adventure != fight.adventure
                logger.warn 'Oops! It is not our player!!'
              else
                pl.real_initiative = $LAST_MATCH_INFO[2].to_i
                pl.save
                fight.update_step_orders
                send_fight ws, fight, player.is_master
              end

            when /^npc_name_grp (\d+)=(.*)/
              npc = NonPlayer.find_by_id($LAST_MATCH_INFO[1])
              if npc && npc.fight_group.adventure == player.adventure
                update_npc_grp(ws, npc, player.adventure) do |n|
                  n.name = $LAST_MATCH_INFO[2]
                end
              else
                logger.warn 'Invalid group. Ignore'
              end

            when /^group2fight (\d+)/
              logger.warn "group2fight #{$LAST_MATCH_INFO[1]}"
              grp = FightGroup.find_by_id($LAST_MATCH_INFO[1])
              if grp && grp.adventure == player.adventure
                grp.to_fight fight
                update_fight_for_all fight
              else
                logger.warn 'Bad fight group. Ignore'
              end

            when /^grp_(\S+) (\d+)=(-?\d+)/
              logger.warn "group-#{$LAST_MATCH_INFO[1]} #{$LAST_MATCH_INFO[2]} =#{$LAST_MATCH_INFO[3]}"
              npc = NonPlayer.find_by_id($LAST_MATCH_INFO[2])
              if npc && npc.fight_group.adventure == player.adventure
                update_npc_grp(ws, npc, player.adventure) do |n|
                  case $LAST_MATCH_INFO[1]
                  when 'hp'
                    n.hp = $LAST_MATCH_INFO[3].to_i
                  when 'max_hp'
                    n.max_hp = $LAST_MATCH_INFO[3].to_i
                  when 'ac'
                    n.armor_class = $LAST_MATCH_INFO[3].to_i
                  when 'init'
                    n.initiative = $LAST_MATCH_INFO[3].to_i
                  else
                    logger.warn "Bad type: #{$LAST_MATCH_INFO[1]}"
                  end
                end
              else
                logger.warn 'Invalid group. Ignore'
              end

            when /^hp (\d+)\/(.)=(-?\d+)/
              logger.warn "fighter #{$LAST_MATCH_INFO[1]} hp=#{$LAST_MATCH_INFO[3]}"
              if $LAST_MATCH_INFO[2] == 'n'
                update_npc(ws, $LAST_MATCH_INFO[1], fight) do |new_npc|
                  new_npc.hp = $LAST_MATCH_INFO[3].to_i
                end
              else
                pl = Player.find_by_id($LAST_MATCH_INFO[1])
                pl.hp = $LAST_MATCH_INFO[3].to_i
                pl.save
                send_fight ws, fight, player.is_master
                send_all(fight_to_json(fight, false)) { |p| !p.is_master }
              end

            when /^max_hp (\d+)=(-?\d+)/
              logger.warn "fighter #{$LAST_MATCH_INFO[1]} max_hp=#{$LAST_MATCH_INFO[2]}"
              update_npc(ws, $LAST_MATCH_INFO[1], fight) do |new_npc|
                new_npc.max_hp = $LAST_MATCH_INFO[2].to_i
                # new_npc.save
                # send_fight ws, fight, player.is_master
              end

            when /^ac (\d+)=(-?\d+)/
              logger.warn "fighter #{$LAST_MATCH_INFO[1]} ac=#{$LAST_MATCH_INFO[2]}"
              update_npc(ws, $LAST_MATCH_INFO[1], fight) do |new_npc|
                new_npc.armor_class = $LAST_MATCH_INFO[2].to_i
                # npc.save
                # send_fight ws, fight, player.is_master
              end

            when 'get_groups'
              ws.send groups_to_json(player.adventure)

            when /^new-group (.*)/
              name = $LAST_MATCH_INFO[1].chomp
              FightGroup.create!(adventure: player.adventure, name: name)
              ws.send groups_to_json(player.adventure)

            when /^del-group (\d+)/
              grp = FightGroup.find_by_id($LAST_MATCH_INFO[1])
              if grp.nil? || (grp.adventure != player.adventure)
                logger.warn 'Bad group number... Ignore.'
              else
                grp.delete
                ws.send groups_to_json(player.adventure)
              end

            # grp_id npc_type num
            when /^add-to-group (\d+) (\d+) (\d+)/
              grp = FightGroup.find_by_id($LAST_MATCH_INFO[1])
              r = NpcType.find_by_id($LAST_MATCH_INFO[2])
              num = $LAST_MATCH_INFO[3].to_i
              logger.warn "grp-new-npc (#{grp} #{r} #{num})"
              if r.nil?
                logger.warn 'No such NPC'
              elsif grp.adventure != player.adventure
                logger.warn 'Not our adventure'
              else
                while num.positive?
                  num -= 1
                  npc = NonPlayer.generate(r, grp)
                  if npc
                    grp.non_players << npc
                    logger.warn 'ok!'
                  else
                    loger.warn 'oooops... npc was not created'
                  end
                end
                grp.save
                ws.send groups_to_json(player.adventure)
              end

            # grp_id npc_id
            when /^del-from-group (\d+) (\d+)/
              grp = FightGroup.find_by_id($LAST_MATCH_INFO[1])
              r = NonPlayer.find_by_id($LAST_MATCH_INFO[2])
              if grp.nil? || r.nil?
                logger.warn 'No such group or NPC. Ignore'
              elsif grp.adventure != player.adventure
                logger.warn 'Not our adventure. Ignore'
              elsif r.fight_group.id != grp.id
                logger.warn 'Not our NPC. Ignore'
              else
                r.delete
                ws.send groups_to_json(player.adventure)
              end

            # change fighter step priority
            when /^step (\d+) (\S+) (\+|-)/
              logger.warn "fighter-step #{$LAST_MATCH_INFO[1]} #{$LAST_MATCH_INFO[2]} #{$LAST_MATCH_INFO[3]} (master=#{player.is_master}, afight=#{player.adventure.active_fight}, rfight=#{player.adventure.ready_fight}"
              is_npc = $LAST_MATCH_INFO[2] == 'true'
              list = fight.get_fighters(player.is_master).sort_by(&:step_order)
              # logger.warn "... #{list.inspect}"
              index = list.index do |x|
                x[:is_npc] == is_npc && x[:id] == $LAST_MATCH_INFO[1].to_i
              end
              if index
                f0 = get_fighter list[index]
                f1 = nil
                if $LAST_MATCH_INFO[3] == '+' && index.positive?
                  f0[:step_order] -= 1
                  f1 = get_fighter list[index - 1]
                  f1[:step_order] += 1
                elsif $LAST_MATCH_INFO[3] == '-' && index < list.size
                  f0[:step_order] += 1
                  f1 = get_fighter list[index + 1]
                  f1[:step_order] -= 1
                else
                  warn 'Ooooops! Bad fighter index!'
                  return
                end
                f1.save
                f0.save
                f = get_fight player
                send_fight ws, f, player.is_master
              else
                warn 'Oooops! no such fighter!'
              end
            else
              logger.warn "Incorrect command '#{text}'. Ignore."
            end
            # case
          else # ! master
            warn 'wat?'
          end
        end
        # case
      rescue => e
        logger.warn "BAD message, got error: #{e.message} (#{e.backtrace.join("\n")})"
      end
    end
  end
end
