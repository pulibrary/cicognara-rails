# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('config/application', __dir__)

Rails.application.load_tasks

require 'bundler/setup'
require 'rubocop/rake_task'
require 'solr_wrapper/rake_task'

desc 'Run RuboCop style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rspec'
  task.fail_on_error = true
end

task :ci do
  ENV['RAILS_ENV'] ||= 'test'
  SolrWrapper.wrap(config: 'config/solr_wrapper_test.yml') do |solr|
    solr.with_collection(name: 'cicognara', dir: File.join(File.expand_path(File.dirname(__FILE__)), 'solr', 'config')) do
      Rake::Task['spec'].invoke
    end
  end
end

task default: :ci
