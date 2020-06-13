#
# frozen_string_literal: true

#
require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra-websocket'
require 'json'
require 'securerandom'
require 'base64'

#
# Top level controller
#
#
class DNDController < BaseApp
  WSregex = Regexp.new '^(\S+): (.*)'

  BASE_PATH = 'http://zhum.freeddns.org:4567'
  AUTH_KEY = 'fgkrtpnbhnwuyfdgvpoeb'
  EXPIRATION_TIME = 3600 * 6 # 6 hours
  SECRET_KEY_REGEXP = /^X-Auth-Key:\s+(\S.*)/i
  SUBJECT_REGEXP = /^Subject:\s+.*(\S.*)/i

  get '/img/player/:player_id' do
    id = params[:player_id].to_i
    logger.warn "Bad id (#{params[:player_id].inspect}!" if id.zero?
    redirect "/img/player_#{id}.png"
  end

  get '/img/:img' do
    redirect '/img/default.jpg'
  end

  # websocket request or redirect to player/master/auth
  get '/' do
    if !request.websocket?
      player_id = session[:player_id].to_i
      if player_id.positive? && Player.find_by_id(player_id)
        if Player.find(player_id).is_master
          redirect '/master'
        else
          redirect '/player'
        end
      else
        redirect '/auth'
      end
    else
      websocket_event request
    end
  end

  def websocket_event(request)
    logger.warn 'Websocket!'
    request.websocket do |ws|
      ws.onopen do
        # logger.warn "Connection " # {ws.methods}"
        # ws.send("Hello World!")
        # settings.sockets
      end
      ws.onmessage do |msg|
        logger.warn "GOT: '#{msg}'"
        on_websocket_message ws, msg
      end
      ws.onclose do
        # warn("websocket closed")
        settings.sockets.delete_if do |k, s|
          logger.warn "Delete socket #{k}"
          s == ws
        end
      end
    end
  end

  #
  # process websocket message
  # @param ws  Websocket
  # @param msg String    text
  #
  # @return ignore it
  def on_websocket_message(ws, msg)
    if WSregex.match msg
      player_id = params[:player_id].to_i
      txt = Regexp.last_match(2)
      user = User.find_by_secret Regexp.last_match(1)
      if user.nil?
        logger.warn t('.bad_secret', m: Regexp.last_match(1))
      else
        on_player_websocket ws, player_id, user, txt
      end
    else
      logger.warn t('.bad_request', msg: msg)
    end
  end

  def on_player_websocket(ws, player_id, user, txt)
    player = Player.find_by_id(player_id)
    if player && player.user == user
      settings.sockets[player_id] ||= ws
      DNDLogic.process_message(
        ws, user, player, txt,
        ws: settings.sockets,
        player: !player.is_master,
        master: player.is_master
      )
    else
      logger.warn "Bad player (#{player_id})"
    end
  end

  # player or master selection
  get '/player_select' do
    # @user = User.find(session[:user_id])
    logger.warn "PLAYER_SELECT ->#{session[:user_id]}"
    @title = 'Выберите кем играть'
    slim :player_select
  end

  # player creation
  get '/player_create' do
    logger.warn 'PLAYER_CREATE'
    logger.warn "PLAYER_SELECT ->#{session[:user_id]}"
    @title = 'Создайте игрока'
    slim :player_create
  end

  # master creation
  get '/master_create' do
    logger.warn 'MASTER_CREATE'
    @title = 'Создайте мастера и приключение'
    slim :mater_create
  end

  get '/logout' do
    session[:player_id] = 0
    session[:secret] = 0
    flash[:warn] = 'Пока!'
    redirect '/auth'
  end

  get '/auth' do
    @title = 'Представьтесь...'
    slim :auth
  end

  def auth_admin
    session[:user_id] = 1
    session[:player_id] = 1001
    session[:secret] = Player.find(1001).secret
    flash[:info] = 'Вход читера!'
    logger.warn 'admin/admin'
    redirect '/'
  end

  def first_redirect(players, masters, session)
    if players.size + masters.size >= 0
      logger.warn "User=#{@user.inspect}"
      logger.warn "player_select! (#{session.inspect})"
      redirect '/player_select'
    else
      @player = players.first
      session[:player_id] = @player.id
      flash[:info] = 'Успешный вход!'
      logger.warn 'OK!'
      redirect '/'
    end
  end

  def auth_password
    session[:user_id] = @user.id
    session[:secret] = @user.secret
    players = @user.players.where(is_master: false)
    masters = @user.players.where(is_master: true)
    first_redirect players, masters, session
  end

  post '/auth' do
    logger.warn "auth: #{params[:email].downcase} / #{params[:password]}"
    @user = User.find_by_email(params[:email].downcase)
    if params[:email].casecmp('admin') && params[:password] == 'admin!'
      auth_admin
    elsif @user&.authorize(params[:password])
      auth_password
    else
      flash[:warn] = 'Неверное сочетание логина и пароля.'
      logger.warn 'Bad auth :('
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
      flash[:warn] = t('.cannot_register')
      logger.warn "Register fail. #{user.errors.full_messages}"
      redirect '/auth'
    end
    session[:user_id] = user.id
    redirect '/player_create'
  end

  get '/reset_password' do
    user = User.find_by_email(params[:email].downcase.strip)
    if user
      str = CredentialsManage.create_onetime_data(
        user: user,
        reset_password: 1,
        expire: Time.now.to_i + EXPIRATION_TIME
      )
      IO.popen("mail -s 'Password reset' #{user.email}", 'w') do |io|
        io.write t('.confirm_password', base: BASE_PATH, str: str)
      end
      flash[:info] = 'Выслали ссылку для сброса пароля на email!'
    else
      flash[:warn] = 'Не нашли в базе такой email!'
    end
    redirect '/auth'
  end

  post '/reset_password' do
    key = params[:pass]
    if key
      data = CredentialsManage.get_ontime_data(key, true)
      if data && data[:reset_password].to_i == 1
        ###########################################################
        ###########################################################
        ###########################################################
      end
    else
      flash[:warn] = 'Не нашли в базе такой email!'
    end
  end

  get '/buy' do
    @player = Player.find(session[:player_id].to_i)
    @item_type = params[:type]
    @items = case params[:type]
             when 'things'
               Thing.all.map do |x|
                 {
                   cost: x.cost,
                   id: x.id,
                   name: x.name,
                   description: x.short_description
                 }
               end
             when 'weapon'
               Weapon.all.map do |x|
                 {
                   cost: x.cost,
                   id: x.id,
                   name: x.name,
                   description: x.short_description
                 }
               end
             when 'armor'
               Armor.all.map do |x|
                 {
                   cost: x.cost,
                   id: x.id,
                   name: x.name,
                   description: x.short_description
                 }
               end
             when 'feature'
               Feature.all.map do |x|
                 {
                   cost: 0,
                   id: x.id,
                   name: x.name,
                   description: x.description
                 }
               end
             when 'spells'
               Spell.all.map do |x|
                 {
                   cost: 0,
                   id: x.id,
                   name: x.name,
                   description: x.description
                 }
               end
             else
               []
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

  get '/api/email' do
    head = true
    passed = false
    subj = nil
    File.open('/tmp/dnd-emails', 'a+') do |io|
      request.rewind.body.read.split("\n") do |line|
        line.chomp!
        if head
          if SECRET_KEY_REGEXP =~ line
            passed = (AUTH_KEY == Regexp.last_match(1))
          elsif SUBJECT_REGEXP =~ line
            subj = Regexp.last_match(1)
          elsif line == ''
            head = false
            return [403, 'Not authorized. Bye.'] unless passed
            io.puts "New mail: #{subj}"
          end
        else # body
          io.puts line
        end
      end
      io.puts '======================='
    end
    [200, 'ok']
  end
end
