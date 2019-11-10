class DNDLogic
  class<<self
    def logger
      $logger
    end

    def process_message ws,user,player,text,opts={}
      case text
      when 'get_player'
        #@player = Player.find(session[:id]||1001)
        logger.warn "id=#{player.id}"
        m = player.to_json
        logger.warn "get_player: '#{m}'"
        ws.send(m)
      when 'chat_message'
        adventure = player.adventure
        #FIXME add messages storing
        if opts[:player]
          master = adventure.master
          socket = opts[:ws]["m#{master.id}"]
          if socket
            socket.send "chat:#{player.name}:#{text}"
          else
            logger.warn "Ouch! master not found!"
          end
        elsif opts[:master]
          adventure.players.each{|p|
            socket = opts[:ws][player.id]
            if socket
              socket.send "chat:MASTER:#{text}"
            else
              logger.warn "Ouch! player #{player_id} (#{player.name}) not found!"
            end
          }
        else
          logger.warn "AAAAAAAAAAAAAA! Bad chat message"
        end
      else
        #settings.sockets.each{|s| s.send(msg) }
        logger.warn 'oops!'
      end
    end
  end
end
