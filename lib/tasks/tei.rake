require 'cicognara/tei_indexer'

namespace :tei do
  namespace :catalogo do
    desc 'Pulls in the Catalogo TEI and MARC'
    task update: :environment do
      teipath = ENV['TEIPATH'] || File.join(File.dirname(__FILE__), '..', '..', 'public', 'cicognara.tei.xml')
      marcpath = ENV['MARCPATH'] || File.join(File.dirname(__FILE__), '..', '..', 'public', 'cicognara.mrx.xml')
      Rails.logger.info "Running tei:catalogo:update with #{teipath}, #{marcpath}"
      catalogo_version = ENV['CATALOGO_VERSION'] || 'main'
      `wget https://raw.githubusercontent.com/pulibrary/cicognara-catalogo/#{catalogo_version}/catalogo.tei.xml -O #{teipath}`
      `wget https://raw.githubusercontent.com/pulibrary/cicognara-catalogo/#{catalogo_version}/cicognara.mrx.xml -O #{marcpath}`
      Rails.logger.info 'Completed tei:catalogo:update'
    end
  end

  desc 'delete solr index'
  task clean_solr: :environment do
    Blacklight.default_index.connection.delete_by_query('*:*')
    Blacklight.default_index.connection.commit
  end

  desc 'index solr documents from path to document at TEIPATH and MARCPATH.'
  task index: :environment do
    teipath = ENV['TEIPATH'] || File.join(File.dirname(__FILE__), '../../', 'spec/fixtures', 'cicognara.tei.xml')
    marcpath = ENV['MARCPATH'] || File.join(File.dirname(__FILE__), '../../', 'spec/fixtures', 'cicognara.marc.xml')
    Rails.logger.info "Running tei:index with #{teipath}, #{marcpath}"
    solr_server = Blacklight.connection_config[:url]
    solr = RSolr.connect(url: solr_server)
    solr.add(Cicognara::TEIIndexer.new(teipath, marcpath).solr_docs)
    solr.commit
    Rails.logger.info 'Completed tei:index'
  end

  desc 'Import Getty data and reindex'
  task reindex: :environment do
    Rails.logger.info 'Running reindex'
    Rake::Task['tei:catalogo:update'].invoke
    Rake::Task['getty:import'].invoke
    Rake::Task['tei:index'].invoke
    Rails.logger.info 'Completed reindex'
  end

  desc 'Create partials at PARTIALSPATH from document at TEIPATH'
  task :partials do
    teipath = ENV['TEIPATH'] || File.join(File.dirname(__FILE__), '../../', 'spec/fixtures', 'cicognara.tei.xml')
    partialspath = ENV['PARTIALSPATH'] || File.join(File.dirname(__FILE__), '../../', 'app/views/pages/catalogo/')
    # Generate section partials
    xslpath = File.join(File.dirname(__FILE__), '../', 'xsl', 'partials-section.xsl')
    system(%(java -jar bin/saxon9he.jar -s:#{teipath} -xsl:#{xslpath} path_to_partials=#{partialspath} url_path_prefix=#{ENV['URL_PATH']} >/dev/null))

    # Generate item partials
    xslpath = File.join(File.dirname(__FILE__), '../', 'xsl', 'partials-item.xsl')
    system(%(java -jar bin/saxon9he.jar -s:#{teipath} -xsl:#{xslpath} path_to_partials=#{partialspath} url_path_prefix=#{ENV['URL_PATH']}))
  end

  desc 'Pulls catalogo tei/marc then indexes and generates partials'
  task :deploy do
    Rake::Task['tei:catalogo:update'].invoke
    Rake::Task['clean_solr'].invoke
    Rake::Task['tei:index'].invoke
    Rake::Task['tei:partials'].invoke
  end
end
