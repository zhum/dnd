class PlayerController < BaseApp
  get '/:player_id' do
    @player = Player.find(params[:player_id])
    if @player.user == @user
      session[:player_id] = params[:player_id]
      redirect '/player'
    else
      session[:user_id] = 0
      redirect '/auth'
    end
  end
  post '/new' do
    @player = Player.create(
      user: @user,
      name: params[:reg_name],
      adventure: Adventure.last # FIXME!!!!!
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

  # player interface
  get '/' do
    @player = Player.find(session[:player_id])
    slim :player
  end

end