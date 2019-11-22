# frozen_string_literal: true

# Don't let these run in production
if Rails.env.development? || Rails.env.test?
  namespace :cico do
    desc 'Run Solr for development'
    task :development do
      SolrWrapper.wrap do |solr|
        solr.with_collection(name: 'cicognara', dir: Rails.root.join('solr', 'config'), persist: true) do
          begin
            puts 'Solr running at http://localhost:8983/solr/cicognara/, ^C to exit'
            sleep
          rescue Interrupt
            puts 'Shutting down...'
          end
        end
      end
    end

    namespace :development do
      desc 'Run Solr and Rails server with tei seed data for interactive development'
      task :server, [:rails_server_args] do |_t, args|
        SolrWrapper.wrap do |solr|
          solr.with_collection(name: 'cicognara', dir: Rails.root.join('solr', 'config'), persist: true) do
            puts 'Indexing TEI...'
            Rake::Task['tei:index'].invoke
            puts 'Generating partials...'
            Rake::Task['tei:partials'].invoke
            begin
              puts 'Starting Rails'
              system "bundle exec rails s #{args[:rails_server_args]}"
            rescue Interrupt
              puts 'Shutting down...'
            end
          end
        end
      end

      desc 'Delete solr index'
      task :clear do
        Blacklight.default_index.connection.delete_by_query('*:*')
      end

      # Ensure your rails server is off before running or you get errors
      desc 'clean solr, db, and run all seeds for small data set'
      task clean_and_seed: :environment do
        Rake::Task['cico:development:clear'].invoke
        Rake::Task['db:drop'].invoke
        Rake::Task['db:setup'].invoke
        Rake::Task['tei:index'].invoke
        Rake::Task['tei:partials'].invoke
        Rake::Task['getty:seed'].invoke
      end
    end

    desc 'Run Solr for test suite'
    task :test do
      ENV['RAILS_ENV'] ||= 'test'
      SolrWrapper.wrap(config: 'config/solr_wrapper_test.yml') do |solr|
        solr.with_collection(name: 'cicognara', dir: Rails.root.join('solr', 'config')) do
          begin
            puts 'Solr running at http://localhost:8888/solr/cicognara/, ^C to exit'
            sleep
          rescue Interrupt
            puts 'Shutting down...'
          end
        end
      end
    end
  end
end
