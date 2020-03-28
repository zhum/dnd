class PlayerController < BaseApp
  post '/new' do
    klass = Klass.find(params.delete(:klass_id))
    race = Race.find(params.delete(:race_id))
    @player = Player.try_create @user, params.merge(klass: klass, race: race)
    unless @player.save
      flash[:warn] = 'Хм... Что-то пошло не так. Не получается зарегистрировать!'
      logger.warn "Register fail."
      redirect '/auth'
    end
    session[:player_id] = @player.id
    flash[:info]='Поздравляем с созданием!'
    redirect '/player'
  end

  # player chat
  get '/msg' do
    @player = Player.find(session[:player_id])
    @title = "Чат с мастером"
    slim :player_chat
  end
  
  # player create
  get '/create' do
    @title = "Создайте персонажа"
    slim :player_create
  end

  # player profile view
  get '/profile' do
    slim :player_profile
  end
  
  # player profile update
  post '/profile' do
    slim :player_profile
  end
  
  # player profile update
  post '/profile/avatar' do
    id = session[:player_id].to_i
    if id > 0
      file_data = params[:data]
      if file_data =~ /data:image\/([a-z]+);base64,(.*)/
        if $1 == 'png'
          File.open("app/static/img/player_#{id}.png","wb"){|f|
            f.write Base64.decode64($2)
          }
          flash[:info] = t('avatar-saved')
        else
          logger.warn "Oooops! Bad image type (#{$1})"
          flash[:warn] = t('something-wrong')
        end
      else
        flash[:warn] = t('something-wrong')
        logger.warn "Oops! Bad form data: #{file_data[0 .. 40]} ..."
      end
    else
      flash[:warn] = t('something-wrong')
    end
    redirect '/player/profile'
    logger.warn "Oops! Unauthorized yet..."
  end
  
  # player interface
  get '/' do
    @player = Player.find(session[:player_id])
    @title = "Игрок"
    # @char_translation = {
    #   'strength' => 'Сил.','constitution' => 'Телосл.',
    #   'dexterity' => 'Ловк.','intellegence' => 'Интел.',
    #   'wisdom' => 'Мудр.','charisma' => 'Харизма'}
    slim :player
  end

  get '/:player_id' do
    @player = Player.find(params[:player_id])
    # @char_translation = {
    #   'strength' => 'Сил.','constitution' => 'Телосл.',
    #   'dexterity' => 'Ловк.','intellegence' => 'Интел.',
    #   'wisdom' => 'Мудр.','charisma' => 'Харизма'}
    if @player.user == @user
      session[:player_id] = params[:player_id]
      redirect '/player'
    else
      session[:user_id] = 0
      redirect '/auth'
    end
  end

end