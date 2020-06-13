# frozen_string_literal: true

#
# Catch RAKE exceptions
#
# @author [serg]
#
class ExceptionHandling
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call env
  rescue => ex
    env['rack.errors'].puts ex
    env['rack.errors'].puts ex.backtrace[0..5].join("\n")
    env['rack.errors'].flush

    # hash = { :message => ex.to_s }
    # hash[:backtrace] ex.backtrace if RACK_ENV['development']

    [500, { 'Content-Type' => 'text/text' }, ex.backtrace[0..5]]
  end
end

#
# Main logger
#
# @author [serg]
#
class DNDLogger
  def self.set_file(f)
    @_file = f
  end

  def self.logger
    if @_logger.nil?
      @_logger = Logger.new(@_file, 10, 10_240_000)
      @_logger.level = Logger::INFO
      @_logger.datetime_format = '%a %Y-%m-%d %H:%M '
    end
    @_logger
  end
end

#
# Base app
#
# @author [serg]
#
class BaseApp < Sinatra::Base
  register Sinatra::Flash

  set :public_folder, "#{File.dirname(__FILE__)}/static"
  set :views, "#{File.dirname(__FILE__)}/views"
  set :bind, '0.0.0.0'
  set :port, 4567

  # enable :sessions
  # set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
  set :logging, true
  use ExceptionHandling
  use Rack::Session::Cookie,
      key: 'rack.session',
      # :domain => 'foo.com',
      path: '/',
      expire_after: 2_592_000, # In seconds
      secret: ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
  # use Rack::Session::Pool, :expire_after => 2592000 # seconds
  use Rack::Protection::RemoteToken
  use Rack::Protection::SessionHijacking

  # Configure ActiveRecord

  env    = ENV['RACK_ENV'] || 'development'
  root   = File.expand_path '..', __FILE__
  conf_file = File.read(File.join(settings.root, '../db/config.yml'))
  config = YAML.safe_load(ERB.new(conf_file).result)

  ActiveRecord::Base.configurations = config
  ActiveRecord::Base.establish_connection env.to_sym

  # Register custom extensions

  configure do
    set :dump_errors, false
    set :raise_errors, true
    set :show_exceptions, false

    # enable :logging
    # $logger = Logger.new("#{settings.root}/../log/#{settings.environment}.log", 10, 10_240_000)
    # $logger.level= Logger::INFO
    # logfile.sync = true
    DNDLogger.set_file "#{settings.root}/../log/#{settings.environment}.log"
    use Rack::CommonLogger, DNDLogger.logger # $logger
    set :logger, DNDLogger.logger # $logger
    ActiveRecord::Base.logger = DNDLogger.logger # $logger

    I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
    I18n.load_path = Dir[File.join(settings.root, 'locales', '*.yml')]
    I18n.backend.load_translations

    if env == 'development'
      # register Sinatra::Reloader
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
    return unless session[:user_id].to_i.zero?
    flash[:warn] = t('auth_failed', path: request.path)
    session[:player_id] = 0
    session[:master_id] = 0
    session[:secret] = ''
    redirect '/auth'
  end

  before do
    # env['rack.errors'] = $logger
    I18n.locale = params[:locale] || :ru
    logger.warn "session: user_id=#{session[:user_id]}; player_id=#{session[:player_id]}; master_id=#{session[:master_id]}; secret=#{session[:secret]}"
    pass if request.path == '/auth' || request.path == '/register'
    if request.websocket? # !!!!!!!!! FIXME! Do auth for websocket too
      pass
    else
      authenticate!
    end
    @user = User.find_by_id(session[:user_id])
    redirect '/auth' if @user.nil?
  end

  include ::AppHelpers
  include ::PartitionHelpers
end
