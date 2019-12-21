env = ENV['HEROKU']==='1' ? 'heroku' : 'development'

warn "Using env=#{env}"

ENV['SINATRA_ENV'] ||= env
ENV['RACK_ENV'] ||= env
ENV['RAILS_ENV'] ||= env

require "./config/environment"


map('/player')        { run PlayerController }
map('/master')        { run MasterController }
map('/')              { run DNDController }
#run DNDController

