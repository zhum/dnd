class DNDLogic
  class<<self
    def logger
      $logger
    end

    def process_message ws,user,player,text,opts={}
      warn "Logic got '#{text}' from #{player.id} #{player.is_master} #{player.name}"
      case text
      when 'hello'
        logger.warn "got hello from #{player.id} (#{player.name})"
        return
      when 'get_master'
        logger.warn "got master request from #{player.id} (#{player.name})"
        return
      # send player info
      when 'get_player'
        #@player = Player.find(session[:id]||1001)
        logger.warn "id=#{player.id}"
        m = "{\"player\": #{player.to_json}}"
        logger.warn "get_player: '#{m}'"
        ws.send(m)
      # send chat history
      when 'get_chat'
        warn "id=#{player.id}"
        messages = if player.is_master
          Message.all
        else
          Message.where(player: player).order(created_at: :asc)
        end
        list = {}
        messages.each{|msg|
          list[msg.player.id] ||= []
          list[msg.player.id] << {
            from: player.is_master ? 
              (msg.to_master ? msg.player.name : 'Я') :
              (msg.to_master ? 'Я' : 'Мастер'),
            text: msg.text
          }
        }
        list.each{|id,lst|
          logger.warn "get_chat: #{id} '#{lst}'"
          message = {'chat_history' => lst}
          if player.is_master
            message['from'] = id
          end
          ws.send(message.to_json)
        }
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
        when 'construction'
          player.mod_construction = value
        when 'charisma'
          player.mod_charisma = value
        else
          logger.warn "Bad modifier #{mod}"
        end
        player.save
        logger.warn "mod_intellegence #{player.mod_intellegence}"
        m = "{\"player\": #{player.to_json}}"
        logger.warn "get_player: '#{m}'"
        ws.send(m)
      when /^message=(.*)/
        message = nil
        begin
          message = JSON.parse($1);
          warn "L1: msg=#{message.inspect}"
          #ws.send({got_message: {id: message['id']}}.to_json)
          message_process ws,user,player,message,opts
        rescue => e
          warn "Cannot process chat message '#{$1}' (#{e.message})"
        end
      else
        #settings.sockets.each{|s| s.send(msg) }
        warn 'oops!'
      end
    end

    def send_message socket, correspondent, from_text, to_master, text, from_id=nil
      #warn "Шлёт мастер?(#{sender_is_master}) Шлёт мастеру?(#{to_master})"
      # from_text = sender_is_master ?
      #   (to_master ? 'Я' : 'Мастер' ) :    # master->self / master -> player
      #   (to_master ? correspondent.name : 'Я')  # player -> master / player -> self
      if socket
        message = {chat: {from: from_text, text: text}}
        message[:from] = from_id if from_id
        warn "SEND(#{from_text}): #{message}"
        socket.send(message.to_json)
        true
      else
        false
      end      
    end

    def message_process ws,user,player,message,opts={}
      adventure = player.adventure
      master = adventure.master
      #is_master = player.id==master.id
      if message['text']==''
        warn "Empty message from #{player.name} (#{player.id})"
        return
      end

      # send back to self
      socket = opts[:ws][player.id]
      warn "self.is_master: #{player.is_master} to self s=#{socket}"
      if ! send_message socket, player, 'Я', !player.is_master, message['text'], message['for']
        warn "Ouch! himself is not found!"
      end

      # send to receiver
      if player.is_master
        reciepient = Player.find(message['for'].to_i)
        if reciepient.nil?
          warn "Bad reciepient (id=#{message['for']})"
          return
        elsif reciepient.adventure!=adventure
          warn "Not involved reciepient (id=#{message['for']})"
          return
        end
        m = Message.create(player: reciepient, to_master: false, text: message['text'])
        m.save
        socket = opts[:ws][reciepient.id]
        warn "player.is_master: #{reciepient.is_master} to #{reciepient.id}/#{reciepient.name} s=#{socket}"
        if ! send_message socket, player, 'Мастер', false, message['text'] #, message['for']
          warn "Ouch! player #{reciepient.name} is not connected now!"
        end

        # adventure.players.where(is_master: false).each { |e|
        #   m = Message.create(player: e, to_master: false, text: message['text'])
        #   m.save
        #   socket = opts[:ws][e.id]
        #   warn "player.is_master: #{e.is_master} to player s=#{socket}"
        #   if ! send_message socket, player, 'Мастер', false, message['text']
        #     warn "Ouch! player #{player.name} is not connected now!"
        #   end
        # }
      else
        # send to master
        socket = opts[:ws][master.id]
        m = Message.create(player: player, to_master: true, text: message['text'])
        m.save
        warn "sender.is_master: #{player.is_master} to master s=#{socket}"
        if ! send_message socket, player, player.name, true, message['text'], player.id
          warn "Ouch! master is not connected!"
        end
      end
    end
  end
end
