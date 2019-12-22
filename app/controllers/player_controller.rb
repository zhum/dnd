class PlayerController < BaseApp
  post '/new' do
    @player = Player.create(
      user: @user,
      name: params[:reg_name],
      adventure: Adventure.find(params[:adventure_id]) #last
      )
    unless @player.save
      flash[:warn] = 'Хм... Что-то пошло не так. Не получается зарегистрировать!'
      logger.warn "Register fail. #{@player.errors.full_messages}"
      redirect '/auth'
    end
    session[:player_id] = @player.id
    flash[:info]='Успешный вход!'
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