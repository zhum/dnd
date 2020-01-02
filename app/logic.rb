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

    def process_message ws,user,player,text,opts={}
      warn "Logic got '#{text}' from #{player.id} #{player.is_master} #{player.name}"
      begin
        case text
        when 'hello'
          logger.warn "got hello from #{player.id} (#{player.name})"
          return
        
        # send master info (NOT USED)
        when 'get_master'
          logger.warn "got master request from #{player.id} (#{player.name})"
          return
        
        # send player info
        when 'get_player'
          #@player = Player.find(session[:id]||1001)
          #sleep 10
          logger.warn "id=#{player.id}"
          send_player ws, player, true

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
          warn "----------------- TYPE=#{type}"
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
            player.armorings << Armoring.create(armor: t, count: 1)
          when 'weapon'
            t = Weapon.find(id)
            if player.weapons.include? t
              logger.warn "Weapon is already bought"
              return
            end
            player.weaponings << Weaponing.create(weapon: t, count: 1)
          end
          if type>0
            warn "------------ Spent: #{t.cost}"
            player.reduce_money(t.cost)
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

        when /^skill\[(\d+)\]=(\d+)/
#          warn ">>>> #{$1}/#{$2}"
          id = $1.to_i
          mod = $2.to_i
          w = player.skillings.where(id: id).take
          warn "!!!!!!!!!!!!!!!!!! skilling=#{w}"
          if mod<1
            logger.warn "Bad skill mod"
          else
            warn "!!!!!!!!!!!!!!!!!! ...."
            w.modifier = mod
            warn "!!!!!!!!!!!!!!!!!! 2"
            w.save
            warn "!!!!!!!!!!!!!!!!!! 3"
            logger.info "Skill: #{w}"
          end
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
          logger.warn "mod_intellegence #{player.mod_intellegence}"
          send_player ws, player

        #chat message
        when /^message=(.*)/
          message = nil
          begin
            message = JSON.parse($1);
            warn "L1: msg=#{message.inspect}"
            #ws.send({got_message: {id: message['id']}}.to_json)
            LogicChat.message_process ws,user,player,message,opts
          rescue => e
            warn "Cannot process chat message '#{$1}' (#{e.message})"
          end
        else
          #settings.sockets.each{|s| s.send(msg) }
          warn "Oops! Message '#{text}' doesnt seems to be parseable...."
        end
      end
    rescue => e
      logger.warn "BAD message, got error: #{e.message} (#{e.backtrace[0..4].join("\n")})"
    end
  end
end
