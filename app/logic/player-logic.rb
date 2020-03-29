class PlayerLogic < DNDLogic
  class<<self

    def update_something opts #id, player, klass, name
      w = opts[:klass].find(opts[:id])
      if w.player != opts[:player]
        logger.warn "Bad #{opts[:name]} - not belongs to player!"
      else
        if opts[:count]<1
          logger.warn "Deleting this #{opts[:name]}"
          w.destroy
        else
          w.count = opts[:count]
          w.save
          logger.info "#{opts[:name]}: #{w}"
        end
        send_player opts[:ws], opts[:player]
      end
    end

    # player, armor/weapon/..., armoring/..., id, {count: N, ...}
    # exclusive = only one element allowed
    def buy player, klass, klass_proxy, id, extra
      logger.warn "BUY! #{id} #{extra}"
      t = klass.find(id)
      exclusive = extra.delete :exclusive
      take_money = extra.delete :money
      name = klass.to_s.downcase.to_sym
      ok = true
      item = klass_proxy.where(player: player, name => t).take
      if item.count > 0 #.armors.include? t
        if exclusive
          logger.warn "#{klass} is already bought"
          ok = false
        else
          item.count += extra[:count] || 1
          item.save
        end
      else
        x = klass_proxy.create!({player: player, name => t}.merge(extra))

        if take_money
          if ! player.reduce_money t.cost
            x.destroy
            ok = false
          end
        end
      end
      logger.warn "success=#{ok}"
      ok
    end

    def process_message ws,user,player,text,opts={}
      logger.warn "Player logic..."
      begin
        case text
        # send player info
        when 'get'
          #@player = Player.find(session[:id]||1001)
          #sleep 10
          logger.warn "id=#{player.id}"
          send_player ws, player, true
          fight = player.adventure.active_fight
          if fight
            FightLogic.send_fight ws, fight, player.is_master
            #ws.send({fighters: fight.get_fighters(player.is_master).sort_by{|x|x[:step_order]}}.to_json)
          end

        # send player preferences info
        when 'prefs'
          m = "{\"prefs\": #{Hash[player.prefs.map{|p| [p.name, p.value]}].to_json}}"
          logger.warn "get_prefs: '#{m}'"
          ws.send(m)
          warn "Sent..."

        # buy
        when /buy (\S+) (\d+)(\s*)(.*)/
          id = $2.to_i
          type = $4.to_i
          logger.warn "----------------- TYPE=#{type}"
          case $1
          when 'things'
            buy player, Thing, Thinging, id, {count: 1, money: 1}
          when 'armor'
            buy player, Armor, Armoring, id, {count: 1, money: 1}
          when 'weapon'
            buy player, Weapon, Weaponing, id, {count: 1, money: 1}
          when 'feature'
            buy player, Feature, Featuring, id, {count: 1, money: 1}
          when 'spells'
            buy player, Spell, Spelling, id, {}
          end
          player.save

        # send chat history
        when 'get_chat'
          LogicChat.get_chat player,ws

        # hp change
        when /^hp=(\d+)/
          hp = $1.to_i
          player.hp = zero_plus hp
          player.save
          send_player ws, player
          logger.info "new hp= #{player.hp}"

        # max_hp change
        when /^max_hp=(\d+)/
          max_hp = $1.to_i
          player.max_hp = zero_plus max_hp
          player.save
          send_player ws, player
          logger.info "new max_hp= #{player.max_hp}"

        # money change
        when /^coins=\[(\d+),(\d+),(\d+),(\d+),(\d+)\]/
          player.mcoins = zero_plus $1.to_i
          player.scoins = zero_plus $2.to_i
          player.gcoins = zero_plus $3.to_i
          player.ecoins = zero_plus $4.to_i
          player.pcoins = zero_plus $5.to_i
          player.save
          send_player ws, player
          logger.info "new gold= #{player.gcoins}"

        # weapon change
        when /^weap (\d+)=(\d+)/
          update_something id: $1.to_i, count: $2.to_i, ws: ws,
            player: player, klass: Weaponing, name: 'weapon'
          # id = $1.to_i
          # count = $2.to_i
          # w = Weaponing.find(id)
          # if w.player == player
          #   if count<1
          #     logger.warn "Deleting this weapon"
          #     w.destroy
          #   else
          #     w.count = count
          #     w.save
          #     logger.info "Weapon: #{w}"
          #   end
          #   send_player ws, player
          # else
          #   logger.warn "Bad weapon - not belongs to player!"
          # end
        when /^skill\[(\d+)\]=(-?\d+)/
          id = $1.to_i
          mod = $2.to_i
          w = player.skillings.where(id: id).take
          # if mod<1
          #   logger.warn "Bad skill mod"
          # else
            w.modifier = mod
            w.save
            logger.info "Skill: #{w}"
          # end
          send_player ws, player

        when /^skill_prof\[(\d+)\]=(\d+)/
          id = $1.to_i
          mod = $2=='1'
          w = player.skillings.where(id: id).take
          w.ready = mod
          w.save
          logger.info "Skill prof: #{w}"
          send_player ws, player

        when /^wear_armor (\d+)=(\d+)/
          id = $1.to_i
          mod = $2=='1'
          w = player.armorings.where(id: id).take
          if w
            w.wear = mod
            w.save
            send_player ws, player
          else
            logger.info "Now such armor! (#{id})"
          end
  
        when /^feature\[(\d+)\]=(\d+)/
#          warn ">>>> #{$1}/#{$2}"
          update_something id: $1.to_i, count: $2.to_i, ws: ws,
            player: player, klass: Featuring, name: 'feature'

          # id = $1.to_i
          # count = $2.to_i
          # w = player.featurings.where(id: id).take
          # if count<1
          #   logger.warn "Bad feature count (#{count})"
          # else
          #   w.count = count
          #   w.save
          #   logger.info "Feature: #{w}"
          # end
          # send_player ws, player

        when /^spells_(\d+)=(\d+)/
          # update_something id: $1.to_i, count: $2.to_i, ws: ws,
          #   player: player, klass: Spelling, name: 'spell'
          i = $1.to_i
          count = $2.to_i
          if count<1
            logger.warn "Bad spell slots count (#{count})"
            count = 0
          end
          player.write_attribute("spell_slots_#{i}",count)
          player.save
          send_player ws, player

        when /^activate_spell=(\d+)/
          i = $1.to_i
          spelling = player.spellings.where(spell_id: i).take
          if spelling.nil?
            logger.warn "Bad spell activate (#{i})"
          else
            affect = SpellAffect.where(spelling: spelling, owner: player).take
            if affect
              affect.delete
            else
              affect = SpellAffect.create(spelling: spelling, owner: player)
              affect.save
            end
            #player.save
            send_player ws, player
          end

        when /^ready_spell=(\d+)/
          i = $1.to_i
          spelling = player.spellings.where(spell_id: i).take
          if spelling.nil?
            logger.warn "Bad spell ready (#{i})"
          else
            spelling.ready = !spelling.ready
            spelling.save
            send_player ws, player
          end

        when /^char\[(\S+)\]=(-?\d+)/
          name = $1
          count = $2.to_i
          w = player.chars.where(name: name).take
          w.value = count
          w.save!
          logger.info "Main char #{name}: #{w.inspect}"
          send_player ws, player

        # armor change
        when /^armor (\d+)=(\d+)/
          update_something id: $1.to_i, count: $2.to_i, ws: ws,
            player: player, klass: Armoring, name: 'armor'
          # id = $1.to_i
          # count = $2.to_i
          # w = Armoring.find(id)
          # if w.player != player
          #   logger.warn "Bad armor - not belongs to player!"
          # else
          #   if count<1
          #     logger.warn "Deleting this armor"
          #     w.destroy
          #   else
          #     w.count = count
          #     w.save
          #     logger.info "armor: #{w}"
          #   end
          #   send_player ws, player
          # end

        # thing change
        when /^thing (\d+)=(\d+)/
          update_something id: $1.to_i, count: $2.to_i, ws: ws,
            player: player, klass: Thinging, name: 'thing'
          # id = $1.to_i
          # count = $2.to_i
          # w = Thinging.find(id)
          # if w.player != player
          #   logger.warn "Bad thing - not belongs to player!"
          # else
          #   if count<1
          #     logger.warn "Deleting this thing"
          #     w.destroy
          #   else
          #     w.count = count
          #     w.save
          #     logger.info "Thing: #{w}"
          #   end
          #   send_player ws, player
          # end

        # savethrow change
        when /^savethrows(\d+)=(\d+)/
          kind = $1.to_i
          count = $2.to_i
          w = player.save_throws.where(kind: kind).take
          if w
            w.count = count
            w.save
          else
            logger.warn "Cannot find savethrow of kind '#{kind}'"
          end
          send_player ws, player

        # set preferences
        when /^pref ([^=]+)=(\S+)/
          name = $1
          value = $2
          begin
            pref = Pref.find_or_create_by(player: player, name: name)
            pref.value = value
            pref.save
          rescue => e
            logger.warn "Bad preference: #{name} = '#{value}' (#{e.message})"
          end

        # modifier change
        when /^mod ([a-z]+)=(.*)/
          mod = $1
          value = $2.to_i
          case mod
          when 'wisdom'
            player.mod_wisdom = value
          when 'intellegence'
            player.mod_intellegence = value
          when 'strength'
            player.mod_strength = value
          when 'dexterity'
            player.mod_dexterity = value
          when 'constitution'
            player.mod_constitution = value
          when 'charisma'
            player.mod_charisma = value
          else
            logger.warn "Bad modifier #{mod}"
          end
          player.save
          send_player ws, player

        # modifier proficiency change
        when /^mod_prof ([a-z]+)=(.*)/
          mod = $1
          value = $2=='1'
          case mod
          when 'wisdom'
            player.mod_prof_wisdom = value
          when 'intellegence'
            player.mod_prof_intellegence = value
          when 'strength'
            player.mod_prof_strength = value
          when 'dexterity'
            player.mod_prof_dexterity = value
          when 'constitution'
            player.mod_prof_constitution = value
          when 'charisma'
            player.mod_prof_charisma = value
          else
            logger.warn "Bad modifier proficiency #{mod}"
          end
          player.save
          send_player ws, player

        #chat message
        when /^message=(.*)/
          message = nil
          begin
            message = JSON.parse($1);
            logger.warn "L1: msg=#{message.inspect}"
            #ws.send({got_message: {id: message['id']}}.to_json)
            LogicChat.message_process ws,user,player,message,opts
          rescue => e
            logger.warn "Cannot process chat message '#{$1}' (#{e.message})"
          end
        else
          #settings.sockets.each{|s| s.send(msg) }
          logger.warn "Oops! Message '#{text}' doesnt seems to be parseable...."
        end
      rescue => e
        logger.warn "BAD message, got error: #{e.message} (#{e.backtrace.join("\n")})"
      end
    end
  end
end
