class DNDLogic
  class<<self
    def logger
      $logger
    end

    def process_message ws,user,player,text,opts={}
      warn "Logic got '#{text}'"
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
            { id: '0',
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

    def send_message socket, from, is_master, to_master, text
      m = Message.create(player: from, to_master: to_master, text: text)
      m.save
      from_text = to_master ?
        (is_master ? from.name : 'Я') :         # player -> master
        (is_master ? 'Я' : 'МАСТЕР')            # master -> player
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
      socket = opts[:ws][master.id]
      warn "to master s=#{socket}"
      if ! send_message socket, player, player==master, true, message['text']
        warn "Ouch! master not found!"
      end

      socket = opts[:ws][player.id]
      warn "to player s=#{socket}"
      if ! send_message socket, player, player==master, false, message['text']
        warn "Ouch! player not found!"
      end
    end
  end
end
