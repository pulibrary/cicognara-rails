namespace :getty do
  desc 'Import resources from Getty'
  task import: :environment do
    Rails.logger.info 'Beginning Import'
    GettyParser.new.import!
    Rails.logger.info 'Committing Solr'
    Blacklight.default_index.connection.commit
    Rails.logger.info 'Import Finished'
  end
end
