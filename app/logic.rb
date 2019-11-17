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
        if true
          messages = Message.where(player: player).order(created_at: :asc)
          list = messages.map{|msg|
            {
              from: msg.to_master ? 'Я' : 'МАСТЕР',
              text: msg.text
            }
          }
          logger.warn "get_chat: '#{list}'"
          ws.send({'chat_history' => list}.to_json)
        else
          warn "Opppppppsssssss....."
        end
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
      m = Message.create(player: correspondent, to_master: to_master, text: text)
      m.save
      warn "Шлёт мастер?(#{sender_is_master}) Шлёт мастеру?(#{to_master})"
      from_text = sender_is_master ?
        (to_master ? 'Я' : 'Мастер' ) :    # master->self / master -> player
        (to_master ? correspondent.name : 'Я')  # player -> master / player -> self
       # to_master ?
       #  (is_master ? 'Я' : correspondent.name) :         # x -> master
       #  (is_master ? 'Я' : 'МАСТЕР')            # x -> player
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
          socket = opts[:ws][e.id]
          warn "player.is_master: #{e.is_master} to player s=#{socket}"
          if ! send_message socket, player, 'Мастер', false, message['text']
            warn "Ouch! player #{player.name} is not connected now!"
          end
        }
      else
        # send to master
        socket = opts[:ws][master.id]
        warn "sender.is_master: #{player.is_master} to master s=#{socket}"
        if ! send_message socket, player, player.name, true, message['text']
          warn "Ouch! master is not connected!"
        end
      end
    end
  end
end
