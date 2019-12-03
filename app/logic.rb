class DNDLogic
  class<<self
    def logger
      $logger
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
          logger.warn "id=#{player.id}"
          send_player ws, player, true

        # send chat history
        when 'get_chat'
          LogicChat.get_chat player,ws

        # hp change
        when /^hp=(\d+)/
          hp = $1.to_i
          player.hp = hp
          player.save
          send_player ws, player
          logger.info "new hp= #{player.hp}"

        # money change
        when /^coins=\[(\d+),(\d+),(\d+),(\d+),(\d+)\]/
          player.mcoins = $1.to_i
          player.scoins = $2.to_i
          player.gcoins = $3.to_i
          player.ecoins = $4.to_i
          player.pcoins = $5.to_i
          player.save
          send_player ws, player
          logger.info "new gold= #{player.gcoins}"

        # weapon change
        when /^weap (\d+)=(.*)/
          id = $1.to_i
          json = JSON.parse($2)
          w = Weapon.find(id)
          if w.player != player
            logger.warn "Bad weapon - not belongs to player!"
            return
          end
          w.count = json['count']
          w.save
          send_player ws, player
          logger.info "Weapon: #{w}"

        # equipment change
        when /^equip (\d+)=(.*)/
          id = $1.to_i
          json = JSON.parse($2)
          w = Equipment.find(id)
          if w.player != player
            logger.warn "Bad equipment - not belongs to player!"
            return
          end
          w.count = json['count']
          w.save
          send_player ws, player
          logger.info "Equip: #{w}"

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
          warn 'oops!'
        end
      end
    rescue => e
      logger.warn "BAD message, got error: #{e.message} (#{e.backtrace[0..4].join("\n")})"
    end
  end
end
