#require './dnd'
#run Sinatra::Application

#require_relative './config/environment'
#require_all 'app'
ENV['SINATRA_ENV'] ||= "development"
ENV['RACK_ENV'] ||= "development"

require 'bundler'

Bundler.require(:default, ENV['SINATRA_ENV'])
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/flash'
#require 'sinatra/reloader'
require 'active_record'
require 'yaml'
require 'json'


Dir.glob('./app/*.rb').each { |file| require file }
Dir.glob('./app/models/*.rb').each { |file| require file }
Dir.glob('./app/controllers/*.rb').each { |file| require file }

map('/player')        { run PlayerController }
map('/master')        { run MasterController }
map('/')              { run DNDController }
#run DNDController

# __END__


# require 'sinatra/base'
# require 'sinatra/json'
# require 'sinatra/flash'
# require 'sinatra/reloader'

# require 'active_record'
# require 'yaml'
# require 'json'

# require "./app"

# Dir.glob("./models/*.rb").sort.each do |file|
#   warn "Loading #{file}"
#   require file
# end

# Dir.glob("./app/*.rb").sort.each do |file|
#   warn "Loading #{file}"
#   require file
# end

# #map "/" do
# run DNDApp
# #end
