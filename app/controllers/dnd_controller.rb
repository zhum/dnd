require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra-websocket'
require 'json'
require "securerandom"
require "base64"

class DNDController < BaseApp
  WSregex = Regexp.new '^(\S+): (.*)'

  # get '/avatar-upload' do
  #   slim :'avatar-upload'    
  # end

  # post '/avatar-upload-crop' do
  #   id = session[:player_id].to_i
  #   if id > 0
  #     file_data = params[:data]
  #     if file_data =~ /data:image\/([a-z]+);base64,(.*)/
  #       if $1 == 'png'
  #         File.open("app/static/img/player_#{id}.png","wb"){|f|
  #           f.write Base64.decode64($2)
  #         }
  #         flash[:info] = t('avatar-saved')
  #         redirect '/player/profile'
  #       else
  #         logger.warn "Oooops! Bad image type (#{$1})"
  #         flash[:warn] = t('something-wrong')
  #         redirect '/avatar-upload'
  #       end
  #     else
  #       flash[:warn] = t('something-wrong')
  #       logger.warn "Oops! Bad form data: #{file_data[0 .. 40]} ..."
  #       redirect '/avatar-upload'
  #     end
  #   else
  #     redirect '/avatar-upload'
  #   end
  # end

  get '/img/player/:player_id' do
    id = params[:player_id].to_i
    if id == 0
      logger.warn "Bad id (#{params[:player_id].inspect}!"
    end
    redirect "/img/player_#{id}.png"
  end

  get '/img/:img' do
    redirect "/img/default.jpg"
  end

  # websocket request or redirect to player/master/auth
  get '/' do
    if !request.websocket?
      player_id = session[:player_id].to_i
      if player_id > 0 && Player.find_by_id(player_id)
        if Player.find(player_id).is_master
          redirect '/master'
        else
          redirect '/player'
        end
      else
        redirect '/auth'
      end
    else
      logger.warn "Websocket!"
      request.websocket do |ws|
        ws.onopen do
          logger.warn "Connection "#{ws.methods}"
          #ws.send("Hello World!")
          #settings.sockets
        end
        ws.onmessage do |msg|
          logger.warn "GOT: '#{msg}'"
          id = nil
          txt = nil
          if WSregex.match msg
            player_id = params[:player_id].to_i
            txt = $2
            user = User.find_by_secret $1
            if user.nil?
              logger.warn "Bad secret: #{$1}"
            else
              player = Player.find_by_id(player_id)
              if player && player.user == user
                settings.sockets[player_id] ||= ws
                DNDLogic.process_message(
                  ws, user, player, txt,
                  ws: settings.sockets,
                  player: !player.is_master,
                  master: player.is_master)
              else
                logger.warn "Bad player (#{player_id})"
              end
            end
          else
            logger.warn "Bad ws request (#{msg})"
          end
        end
        ws.onclose do
          #warn("websocket closed")
          settings.sockets.delete_if{|k,s| logger.warn "Delete socket #{k}";s==ws}
        end
      end
    end
  end

  # player or master selection
  get '/player_select' do
    #@user = User.find(session[:user_id])
    logger.warn "PLAYER_SELECT ->#{session[:user_id]}"
    @title = "Выберите кем играть"
    slim :player_select
  end

  # player creation
  get '/player_create' do
    logger.warn "PLAYER_CREATE"
    logger.warn "PLAYER_SELECT ->#{session[:user_id]}"
    @title = "Создайте игрока"
    slim :player_create
  end

  # master creation
  get '/master_create' do
    logger.warn "MATER_CREATE"
    @title = "Создайте мастера и приключение"
    slim :mater_create
  end

  get '/logout' do
    session[:player_id]=0
    session[:secret]=0
    flash[:warn]='Пока!'
    redirect '/auth'
  end

  get '/auth' do
    @title = "Представьтесь..."
    slim :auth
  end

  post '/auth' do
    logger.warn "auth: #{params[:email].downcase} / #{params[:password]}"
    @user = User.find_by_email(params[:email].downcase)
    if params[:email].downcase=='admin' && params[:password]=='admin!'
      session[:user_id]=1
      session[:player_id]=1001
      session[:secret]=Player.find(1001).secret
      flash[:info]='Вход читера!'
      logger.warn "admin/admin"
      redirect '/'
    elsif @user && @user.authorize(params[:password])
      session[:user_id]=@user.id
      session[:secret]=@user.secret
      players = @user.players.where(is_master: false)
      masters = @user.players.where(is_master: true)
      if players.size+masters.size >= 0
        logger.warn "User=#{@user.inspect}"
        logger.warn "player_select! (#{session.inspect})"
        redirect '/player_select'
      else
        @player = players.first
        session[:player_id]=@player.id
        flash[:info]='Успешный вход!'
        logger.warn "OK!"
        redirect '/'
      end
    else
      flash[:warn]='Неверное сочетание логина и пароля.'
      logger.warn "Bad auth :("
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
      password: params[:reg_pass],
      active: true,
      secret: SecureRandom.alphanumeric(32)
      )
    unless user.save
      flash[:warn] = 'Хм... Что-то пошло не так. Не получается зарегистрировать!..'
      logger.warn "Register fail. #{user.errors.full_messages}"
      redirect '/auth'
    end
    session[:user_id] = user.id
    redirect '/player_create'
  end

  get '/buy' do
    @player = Player.find(session[:player_id].to_i)
    @item_type = params[:type]
    case params[:type]
    when 'things'
      @items = Thing.all.map{|x| {cost: x.cost, id: x.id, name: x.name, description: x.short_description}}
    when 'weapon'
      @items = Weapon.all.map{|x| {cost: x.cost, id: x.id, name: x.name, description: x.short_description}}
    when 'armor'
      @items = Armor.all.map{|x| {cost: x.cost, id: x.id, name: x.name, description: x.short_description}}
    when 'feature'
      @items = Feature.all.map{|x| {cost: 0, id: x.id, name: x.name, description: x.description}}
    when 'spells'
      @items = Spell.all.map{|x| {cost: 0, id: x.id, name: x.name, description: x.description}}
    else
      @items = []
    end
    slim :buy
  end

  get '/note' do
    slim :nothing_here
  end

  get '/rules' do
    slim :nothing_here
  end

  get '/map' do
    slim :nothing_here
  end
end