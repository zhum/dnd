class DNDLogic
  class<<self
    def logger
      $logger
    end

    def zero_plus(x)
      x >= 0 ? x : 0
    end

    def send_player ws, player, logit=false
      m = "{\"player\": #{player.to_json}}"
      logger.warn "get_player: '#{m}'" if logit
      ws.send(m)
    end

    def send_flash ws, flash, logit=false
      m = "{\"flash\": \"#{flash}\"}"
      logger.warn "flash: #{m}" if logit
      ws.send(m)
    end

    def process_message ws,user,player,text,opts={}
      logger.warn "Logic got '#{text}' from #{player.id} #{player.is_master} #{player.name}"
      begin
        case text
        when 'hello'
          logger.warn "got hello from #{player.id} (#{player.name})"
          return
        
        # send master info (NOT USED)
        when 'get_master'
          logger.warn "got master request from #{player.id} (#{player.name})"
          return

        when /new-npc (\d+) (\d+)/
          logger.warn "new-npc"
          f = Fight.find_by_id($1)
          r = Race.find_by_id($2)
          return if r.nil? or f.nil? or f.adventure != player.adventure
          npc = NonPlayer.generate(r, f)
          if npc.save
            f.update_step_orders
            #players = player.adventure.players.where(is_master: false).select(:name,:race,:hp,:max_hp,:initiative)
            ws.send({fighters: f.get_fighters.sort_by{|x|x[:step_order]}}.to_json)
          end

        when /get_fight (\d+)/
          logger.warn "get_fight"
          f = Fight.find_by_id($1)
          return if f.nil? or f.adventure != player.adventure
          ws.send({fighters: f.get_fighters.sort_by{|x|x[:step_order]}}.to_json)
          
        # send player info
        when 'get_player'
          #@player = Player.find(session[:id]||1001)
          #sleep 10
          logger.warn "id=#{player.id}"
          send_player ws, player, true
          fights = player.adventure.fights.where(active: true)
          if fights.count>0
            ws.send({fighters: fights.take.get_fighters.sort_by{|x|x[:step_order]}}.to_json)
          end

        # send player preferences info
        when 'get_prefs'
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
            t = Thing.find(id)
            if player.things.include? t
              logger.warn "Thing is already bought"
              return
            end
            player.thingings << Thinging.create(thing: t, count: 1)
          when 'armor'
            t = Armor.find(id)
            if player.armors.include? t
              logger.warn "Armor is already bought"
              return
            end
            Armoring.create(player: player, armor: t, count: 1).save
          when 'weapon'
            t = Weapon.find(id)
            if player.weapons.include? t
              logger.warn "Weapon is already bought"
              return
            end
            player.weaponings << Weaponing.create(weapon: t, count: 1)
          when 'feature'
            t = Feature.find(id)
            if player.features.include? t
              logger.warn "Feature is already bought"
              return
            end
            player.featurings << Featuring.create(feature: t, count: 1)
          when 'spells'
            t = Spell.find(id)
            if player.spells.include? t
              logger.warn "Spell is already bought"
              return
            end
            player.spellings << Spelling.create(spell: t)
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
          id = $1.to_i
          count = $2.to_i
          w = Weaponing.find(id)
          if w.player != player
            logger.warn "Bad weapon - not belongs to player!"
            return
          end
          if count<1
            logger.warn "Deleting this weapon"
            w.destroy
          else
            w.count = count
            w.save
            logger.info "Weapon: #{w}"
          end
          send_player ws, player

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
          else
            logger.info "Now such armor! (#{id})"
            return
          end
          w.save
          send_player ws, player
  
        when /^feature\[(\d+)\]=(\d+)/
#          warn ">>>> #{$1}/#{$2}"
          id = $1.to_i
          count = $2.to_i
          w = player.featurings.where(id: id).take
          if count<1
            logger.warn "Bad feature count (#{count})"
          else
            w.count = count
            w.save
            logger.info "Feature: #{w}"
          end
          send_player ws, player

        when /^spells_(\d+)=(\d+)/
          i = $1.to_i
          count = $2.to_i
          if count<1
            logger.warn "Bad spell slots count (#{count})"
          else
            player.write_attribute("spell_slots_#{i}",count)
            player.save
          end
          send_player ws, player

        when /^activate_spell=(\d+)/
          i = $1.to_i
          spelling = player.spellings.where(spell_id: i).take
          if spelling.nil?
            logger.warn "Bad spell activate (#{i})"
            return
          end
          affect = SpellAffect.where(spelling: spelling, owner: player).take
          if affect
            affect.delete
          else
            affect = SpellAffect.create(spelling: spelling, owner: player)
            affect.save
          end
          #player.save
          send_player ws, player

        when /^ready_spell=(\d+)/
          i = $1.to_i
          spelling = player.spellings.where(spell_id: i).take
          if spelling.nil?
            logger.warn "Bad spell ready (#{i})"
            return
          end
          spelling.ready = !spelling.ready
          spelling.save
          send_player ws, player

        when /^char\[(\S+)\]=(-?\d+)/
          name = $1
          count = $2.to_i
          w = player.chars.where(name: name).take
          # if count<1
          #   logger.warn "Bad main char count (#{count})"
          # else
            w.value = count
            w.save!
            logger.info "Main char #{name}: #{w.inspect}"
          send_player ws, player

        # armor change
        when /^armor (\d+)=(\d+)/
          id = $1.to_i
          count = $2.to_i
          w = Armoring.find(id)
          if w.player != player
            logger.warn "Bad armor - not belongs to player!"
            return
          end
          if count<1
            logger.warn "Deleting this armor"
            w.destroy
          else
            w.count = count
            w.save
            logger.info "armor: #{w}"
          end
          send_player ws, player

        # thing change
        when /^thing (\d+)=(\d+)/
          id = $1.to_i
          count = $2.to_i
          w = Thinging.find(id)
          if w.player != player
            logger.warn "Bad thing - not belongs to player!"
            return
          end
          if count<1
            logger.warn "Deleting this thing"
            w.destroy
          else
            w.count = count
            w.save
            logger.info "Thing: #{w}"
          end
          send_player ws, player

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

        # # equipment change
        # when /^equip (\d+)=(.*)/
        #   id = $1.to_i
        #   json = JSON.parse($2)
        #   w = Equipment.find(id)
        #   if w.player != player
        #     logger.warn "Bad equipment - not belongs to player!"
        #     return
        #   end
        #   w.count = json['count']
        #   w.save
        #   send_player ws, player
        #   logger.info "Equip: #{w}"

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
      end
    rescue => e
      logger.warn "BAD message, got error: #{e.message} (#{e.backtrace.join("\n")})"
    end
  end
end
