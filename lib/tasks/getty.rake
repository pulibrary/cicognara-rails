namespace :getty do
  desc 'Import resources from Getty'
  task import: :environment do
    Rails.logger.info 'Beginning getty:import'
    GettyParser.new.import!
    Rails.logger.info 'Committing Solr'
    Blacklight.default_index.connection.commit
    Rails.logger.info 'Import finished getty:import'
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

  desc 'Produces the MARC XML with records that need to be manually added to cicognara.mrx.xml'
  task :generate_marc_patch do
    template = File.read("./lib/assets/marc_template.xml")
    hul_patches.each do |patch|
      marc_record = template.gsub("dcl-placeholder", patch[:dcl]).gsub("cico-placeholder", patch[:cico])
      puts marc_record
    end
  end

  desc 'Produces the lines to insert into cicognara.tei.xml'
  task :generate_tei_patch do
    hul_patches.each do |patch|
      puts "n=\"#{patch[:cico]}\" corresp=\"#{patch[:dcl]}\""
    end
  end

  # The mappings between the cico and the dcl were taken from the files downloaded from Getty
  # and that failed to import due to "no matching Book entry" error.
  #
  # See this issue for details. https://github.com/pulibrary/cicognara-rails/issues/544
  #
  # The values are indicated on each of the individual JSON files for Harvard (hul_*.json).
  def hul_patches
    patches = []
    patches << { cico: "2880", dcl: "dcl:8w6/vol01" }
    patches << { cico: "365", dcl: "dcl:nw6" }
    patches << { cico: "1430", dcl: "dcl:jcv" }
    patches << { cico: "2800", dcl: "dcl:0m3" }
    patches << { cico: "3023", dcl: "dcl:6st" }
    patches << { cico: "4063", dcl: "dcl:9ks" }
    patches << { cico: "3202", dcl: "dcl:jwk" }
    patches << { cico: "2074", dcl: "dcl:p0k" }
    patches << { cico: "1244", dcl: "dcl:vs9" }
    patches << { cico: "3030", dcl: "dcl:ckv" }
    patches << { cico: "1357", dcl: "dcl:p35" }
    patches << { cico: "4290", dcl: "dcl:6cq/vol01" }
    patches << { cico: "4786", dcl: "dcl:cd4" }
    patches << { cico: "1636", dcl: "dcl:c6c" }
    patches << { cico: "3944", dcl: "dcl:111" }
    patches << { cico: "2470", dcl: "dcl:4x6" }
    patches << { cico: "479", dcl: "dcl:m8v" }
    patches << { cico: "4271", dcl: "dcl:scb/vol01" }
  end
end
