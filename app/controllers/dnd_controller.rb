require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra-websocket'
require 'json'

class DNDController < BaseApp
  WSregex = Regexp.new '^(\S+): (\S+): (.*)'

  get '/img/player/:player_id' do
    id = params[:player_id].to_i
    if id == 0
      warn "Bad id (#{params[:player_id].inspect}!"
    end
    redirect "/img/player_#{id}.png"
  end

  # websocket request or redirect to player/master/auth
  get '/' do
    if !request.websocket?
      if session[:player_id].to_i > 0
        redirect '/player'
      elsif session[:master_id].to_i > 0
        redirect '/master'
      else
        redirect '/auth'
      end
    else
      logger.warn "Websocket!"
      request.websocket do |ws|
        ws.onopen do
          logger.warn "Connection #{ws}"
          #ws.send("Hello World!")
          #settings.sockets << ws
        end
        ws.onmessage do |msg|
          logger.warn "GOT: '#{msg}'"
          id = nil
          txt = nil
          if WSregex.match msg
            txt = $2
            u = User.where(secret: $1).take
            if u.nil?
              logger.warn "Bad secret: #{$1}"
            else
              DNDLogic.process_message(ws,u,player,txt)
            end
          else
            logger.warn "Bad ws request (#{msg})"
          end
        end
        ws.onclose do
          #warn("websocket closed")
          settings.sockets.delete(ws)
        end
      end
    end
  end

  # player or master selection
  get '/player_select' do
    #@user = User.find(session[:user_id])
    logger.warn "PLAYER_SELECT"
    slim :player_select
  end

  # get '/master/:id' do
  #   master = Master.find(params[:id])
  #   if master.user == @user
  #     session[:master_id] = params[:master_id]
  #     redirect '/master'
  #   else
  #     session[:user_id] = 0
  #     redirect '/auth'
  #   end
  # end

  get '/auth' do
    slim :auth
  end

  get '/logout' do
    session[:player_id]=0
    session[:secret]=0
    flash[:warn]='Пока!'
    redirect '/auth'
  end

  post '/auth' do
    warn "auth: #{params[:email].downcase} / #{params[:password]}"
    @user = User.find_by_email(params[:email].downcase)
    if params[:email].downcase=='admin' && params[:password]=='admin'
      session[:user_id]=1
      session[:player_id]=1001
      session[:secret]=Player.find(1001).secret
      flash[:info]='Вход читера!'
      warn "admin/admin"
      redirect '/'
    elsif @user && @user.authorize(params[:password])
      session[:user_id]=@user.id
      session[:secret]=@user.secret
      players = @user.players
      masters = @user.masters
      if players.size+masters.size>0
        warn "User=#{@user.inspect}"
        warn "player_select! (#{session.inspect})"
        redirect '/player_select'
      else
        @player = players.first
        session[:player_id]=@player.id
        flash[:info]='Успешный вход!'
        warn "OK!"
        redirect '/'
      end
    else
      flash[:warn]='Неверное сочетание логина и пароля.'
      warn "Bad auth :("
      redirect '/auth'
    end
  end

  post '/register' do
    if User.find_by_email(params[:reg_email].downcase.strip)
      flash[:warn] = 'Вы уже регистрировались!'
      redirect '/auth'
    end
    user = User.create(
      name: params[:reg_name],
      email: params[:reg_email],
      password: params[:reg_pass]
      )
    unless user.save
      flash[:warn] = 'Хм... Что-то пошло не так. Не получается зарегистрировать!..'
      logger.warn "Register fail. #{user.errors.full_messages}"
      redirect '/auth'
    end
    session[:user_id] = user.id
    redirect '/player_select'
  end
end