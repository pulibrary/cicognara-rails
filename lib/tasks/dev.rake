# frozen_string_literal: true

# Don't let these run in production
if Rails.env.development? || Rails.env.test?
  namespace :cico do
    namespace :development do
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
  end
end
