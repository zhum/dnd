class MasterController < BaseApp
  # master interface
  get '/' do
    @player = Player.find(session[:player_id])
    slim :master, locals: {title: "Переписка с игроками"}
  end

  # Chat
  get '/msg' do
    @player = Player.find(session[:player_id])
    @adventure = @player.adventure
    @title = "Чат с игроками"
    slim :master_chat
  end

  #...
  get '/:player_id' do
    @player = Player.find(params[:player_id])
    if @player.user == @user
      session[:player_id] = params[:player_id]
      session[:master_id] = params[:player_id]
      redirect '/master'
    else
      session[:user_id] = 0
      redirect '/auth'
    end
  end

end