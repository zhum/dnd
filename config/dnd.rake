
namespace :dnd do
  # task :load_config do
  #   require File.expand_path('../app', __FILE__)
  # end

  # added these lines to work
  desc "Load data from data.yml"
  task :load_config do
    Service.load_all
  end

  desc "Force load data from data.yml"
  task :force_load_config  do
    Service.load_all true
  end
end
