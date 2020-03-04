class MasterController < BaseApp

  # TODO: check he is real master...
  before /.*/ do
    if request.path_info=='/new' or request.path_info =~ /^\/\d+$/
      pass
    else
      @player = Player.find_by_id(session[:player_id]) || Player.find_by_id(session[:master_id])
      logger.warn "master_id=#{session[:master_id]} player_id=#{session[:player_id]} -> player=#{@player.id}"
      redirect '/auth' unless @player
    end
  end

  # master interface
  get '/' do
    slim :master, locals: {title: "Гейм мастер"}
  end

  # Chat
  get '/msg' do
    #@player = Player.find(session[:player_id])
    @adventure = @player.adventure
    @title = "Чат с игроками"
    slim :master_chat
  end

  post '/new' do
    adventure = Adventure.create(name: params[:adventure])
    adventure.save
    @player = Player.create(
      user: @user,
      adventure: adventure,
      name: params[:reg_name],
      is_master: true)
    @player.save
    session[:player_id] = @player.id
    session[:master_id] = @player.id
    redirect '/master'
  end

  # get '/new-fight' do
  #   @fight = @player.adventure.active_fight || @player.adventure.ready_fight
  #   @fight ||= Fight.make_fight(adventure: @player.adventure)
  #   @title = "Создание боя"
  #   slim :new_fight
  # end

  #...
  get '/:player_id' do
    @player = Player.find(params[:player_id])
    logger.warn "--- user_id=#{@user.id} player​‌​=#{@player} #{@player.user.id}"
    if @player.user.id == @user.id
      session[:player_id] = params[:player_id]
      session[:master_id] = params[:player_id]
      redirect '/master'
    else
      session.clear
      redirect '/auth'
    end
  end

end