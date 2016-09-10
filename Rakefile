# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

require 'bundler/setup'
require 'rubocop/rake_task'
require 'solr_wrapper/rake_task'

desc 'Run Solr and Blacklight for interactive development'
task :server, [:rails_server_args] do |_t, args|
  SolrWrapper.wrap do |solr|
    solr.with_collection(name: 'cicognara', dir: File.join(File.expand_path(File.dirname(__FILE__)), 'solr', 'config')) do
      Rake::Task['tei:index'].invoke
      Rake::Task['tei:partials'].invoke
      begin
        system "bundle exec rails s #{args[:rails_server_args]}"
      rescue Interrupt
        puts 'Shutting down...'
      end
    end
  end
end

desc 'Run RuboCop style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rspec'
  task.fail_on_error = true
end

task :ci do
  SolrWrapper.wrap(port: 8888) do |solr|
    solr.with_collection(name: 'cicognara', dir: File.join(File.expand_path(File.dirname(__FILE__)), 'solr', 'config')) do
      Rake::Task['spec'].invoke
    end
  end
end

task default: :ci
