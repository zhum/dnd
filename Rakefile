# Rakefile
#require 'sinatra/activerecord/rake'
#require './dnd'
#
#
require 'yaml'
require 'logger'
require 'active_record'
require 'sinatra/activerecord/rake'
require 'erb'

include ActiveRecord::Tasks

class Seeder
  def initialize(seed)
    @seed = seed
  end

  def load_seed
    raise "Seed file '#{@seed}' does not exist" unless File.file? @seed
    load @seed_file
  end
end


root = File.expand_path '..', __FILE__
DatabaseTasks.env = ENV['RACK_ENV'] || 'development'
conf = File.join root, 'db/config.yml'
yml = ERB.new(File.read(conf)).result
#warn "Conf=#{yml}"
DatabaseTasks.database_configuration = YAML.load(yml)
DatabaseTasks.db_dir = File.join root, 'db'
DatabaseTasks.fixtures_path = File.join root, 'test/fixtures'
DatabaseTasks.migrations_paths = [File.join(root, 'db/migrate')]
DatabaseTasks.seed_loader = Seeder.new File.join root, 'db/seeds.rb'
DatabaseTasks.root = root


task :environment do
  ActiveRecord::Base.configurations = DatabaseTasks.database_configuration
  warn "..."
  ActiveRecord::Base.establish_connection DatabaseTasks.env.to_sym
  warn ":::"
end

load 'active_record/railties/databases.rake'

