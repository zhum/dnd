class MasterController < BaseApp
  # master interface
  get '/' do
    @master = Master.find(session[:master_id])
    slim :master
  end

  #...
  get '/:master_id' do
    master = Master.find(params[:master_id])
    if master.user == @user
      session[:master_id] = params[:master_id]
      redirect '/master'
    else
      session[:user_id] = 0
      redirect '/auth'
    end
  end

  # Chat
  get '/msg' do
    @master = Master.find(session[:master_id])
    slim :master_chat
  end
end