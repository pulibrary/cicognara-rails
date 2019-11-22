namespace :getty do
  desc 'Import resources from Getty'
  task import: :environment do
    Rails.logger.info 'Beginning Import'
    GettyParser.new.import!
    Rails.logger.info 'Committing Solr'
    Blacklight.default_index.connection.commit
    Rails.logger.info 'Import Finished'
  end

  desc 'Import subset of getty resources that matches tei fixtures'
  task seed: :environment do
    Rails.logger.info 'Beginning Import'
    records = []
    dir = Rails.root.join('spec', 'fixtures', 'getty_seeds', '*.json')
    Dir.glob(dir).each do |file|
      records << GettyParser::GettyRecord.from(JSON.parse(File.open(file).read))
    end
    GettyParser::Importer.new(records: records).import!
    Rails.logger.info 'Committing Solr'
    Blacklight.default_index.connection.commit
    Rails.logger.info 'Import Finished'
  end
end
