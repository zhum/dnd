ENV['RACK_ENV'] ||= "development"

warn "============ #{ENV['RACK_ENV']} ================="
require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'])

case ENV['RACK_ENV']
when 'heroku'
	warn "Setup heroku"
  ActiveRecord::Base.establish_connection(
    :adapter => "postgresql",
    :encoding => 'unicode',
    :url => ENV['DATABASE_URL'],
    :pool => 50
  )
when 'development'
	warn "Setup development"
  ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => "dnd.sqlite3",
    :pool => 50
  )
else
  raise "Bad environment '#{ENV['RACK_ENV']}"
end

#require './app'
#warn "Load app"
Dir.glob('./app/helpers/*.rb').each { |file| require file }
Dir.glob('./app/*.rb').each { |file| require file }
Dir.glob('./app/models/*.rb').each { |file| require file }
Dir.glob('./app/controllers/*.rb').each { |file| require file }
#warn "loaded..."
