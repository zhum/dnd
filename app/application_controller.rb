class BaseApp < Sinatra::Base

  register Sinatra::Flash

  set :public_folder, "#{File.dirname(__FILE__)}/static"
  set :views, "#{File.dirname(__FILE__)}/views"
  set :bind, '0.0.0.0'
  set :port, 4567

  #enable :sessions
  #set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
  set :logging, true
  use Rack::Session::Cookie,
    :key => 'rack.session',
    #:domain => 'foo.com',
    :path => '/',
    :expire_after => 2592000, # In seconds
    :secret => ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
  #use Rack::Session::Pool, :expire_after => 2592000 # seconds
  use Rack::Protection::RemoteToken
  use Rack::Protection::SessionHijacking


  # Configure ActiveRecord

  env    = ENV['RACK_ENV'] || 'development'
  root   = File.expand_path '..', __FILE__
  conf_file = File.read(File.join(settings.root,'../db/config.yml'))
  config = YAML.load(ERB.new(conf_file).result)

  ActiveRecord::Base.configurations = config
  ActiveRecord::Base.establish_connection env.to_sym

  # Register custom extensions

  configure do
    #enable :logging
    $logger = Logger.new("#{settings.root}/../log/#{settings.environment}.log", 10, 10_240_000)
    #logfile.sync = true
    use Rack::CommonLogger, $logger
    set :logger, $logger

    I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
    I18n.load_path = Dir[File.join(settings.root, 'locales', '*.yml')]
    I18n.backend.load_translations

    if env == 'development'
      #register Sinatra::Reloader 
      Dir.glob("#{root}/app/models/*.rb").each do |file|
        also_reload file
      end
      Dir.glob("#{root}/app/conreollers/*.rb").each do |file|
        also_reload file
      end
      Dir.glob("#{root}/app/*.rb").each do |file|
        also_reload file
      end

      # after_reload do
      #   logger.warn "Reloaded!"
      # end
    end
  end

  set :sockets, {}

  def authenticate!
    if session[:user_id].to_i==0
      flash[:warn]="Упс! переход на #{request.path} невозможен - не удалась аутентификация :("
      redirect '/auth'
    end
  end

  before do
    #env['rack.errors'] = $logger
    logger.warn "session: user_id=#{session[:user_id]}; player_id=#{session[:player_id]}; master_id=#{session[:master_id]}; secret=#{session[:secret]}"
    return if request.path=='/auth' or request.path=='/register'
    I18n.locale = 'ru' || params[:locale]
    unless request.websocket? #!!!!!!!!! FIXME! Do auth for websocket too
      authenticate!
    end
    @user = User.find_by_id(session[:user_id])
    if @user.nil?
      redirect '/auth'
    end
  end

  include ::AppHelpers
  include ::PartitionHelpers
end
