# Rakefile
#require 'sinatra/activerecord/rake'
#require './dnd'
#
#
require "./config/environment"
require 'active_record'
require 'sinatra/activerecord/rake'
require 'rake/testtask'

load 'active_record/railties/databases.rake'

namespace :db do
  # task :load_config do
  #   require File.expand_path('../app', __FILE__)
  # end

  # added these lines to work
  task seed: :load_config do
    Service.load_all
  end

  task seed: :force_load_config do
    Service.load_all true
  end
end
