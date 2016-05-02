# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

require 'solr_wrapper/rake_task'


namespace :blacklight do
  desc 'Run Solr and Blacklight for interactive development'
  task :server, [:rails_server_args] do |t, args|
    SolrWrapper.wrap do |solr|
    	solr.with_collection(name: 'cicognara', dir: File.join(File.expand_path(File.dirname(__FILE__)), "solr", "config")) do
      	system "bundle exec rails s #{args[:rails_server_args]}"
      end
    end
  end
end