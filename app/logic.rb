class DNDLogic
  class<<self
    def logger
      $logger
    end

    def process_message ws,user,player,text
      case text
      when 'get_player'
        #@player = Player.find(session[:id]||1001)
        logger.warn "id=#{player.id}"
        m = player.to_json
        logger.warn "get_player: '#{m}'"
        ws.send(m)
      else
        #settings.sockets.each{|s| s.send(msg) }
        logger.warn 'oops!'
      end
    end
  end
end
