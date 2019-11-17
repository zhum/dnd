class DNDLogic
  class<<self
    def logger
      $logger
    end

    def process_message ws,user,player,text,opts={}
      warn "Logic got '#{text}' from #{player.id} #{player.is_master} #{player.name}"
      case text
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
        list = messages.map{|msg|
          {
            from: player.is_master ? 
              (msg.to_master ? msg.player.name : 'Я') :
              (msg.to_master ? 'Я' : 'Мастер'),
            text: msg.text
          }
        }
        logger.warn "get_chat: '#{list}'"
        ws.send({'chat_history' => list}.to_json)
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

    def send_message socket, correspondent, from_text, to_master, text
      #warn "Шлёт мастер?(#{sender_is_master}) Шлёт мастеру?(#{to_master})"
      # from_text = sender_is_master ?
      #   (to_master ? 'Я' : 'Мастер' ) :    # master->self / master -> player
      #   (to_master ? correspondent.name : 'Я')  # player -> master / player -> self
      if socket
        socket.send({chat: {from: from_text, text: text}}.to_json)
        true
      else
        false
      end      
    end

    def message_process ws,user,player,message,opts={}
      adventure = player.adventure
      master = adventure.master
      #is_master = player.id==master.id

      # send back to self
      socket = opts[:ws][player.id]
      warn "self.is_master: #{player.is_master} to self s=#{socket}"
      if ! send_message socket, player, 'Я', !player.is_master, message['text']
        warn "Ouch! himself is not found!"
      end

      # send to receiver
      if player.is_master
        #FIXME! send to selected player!
        adventure.players.where(is_master: false).each { |e|
          m = Message.create(player: e, to_master: false, text: message['text'])
          m.save
          socket = opts[:ws][e.id]
          warn "player.is_master: #{e.is_master} to player s=#{socket}"
          if ! send_message socket, player, 'Мастер', false, message['text']
            warn "Ouch! player #{player.name} is not connected now!"
          end
        }
      else
        # send to master
        socket = opts[:ws][master.id]
        m = Message.create(player: player, to_master: true, text: message['text'])
        m.save
        warn "sender.is_master: #{player.is_master} to master s=#{socket}"
        if ! send_message socket, player, player.name, true, message['text']
          warn "Ouch! master is not connected!"
        end
      end
    end
  end
end
