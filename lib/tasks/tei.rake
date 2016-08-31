require 'cicognara/tei_indexer'

namespace :tei do
  desc 'index solr documents from path to document at TEIPATH and MARCPATH.'
  task :index do
    teipath = ENV['TEIPATH'] || File.join(File.dirname(__FILE__), '../../', 'spec/fixtures', 'cicognara.tei.xml')
    marcpath = ENV['MARCPATH'] || File.join(File.dirname(__FILE__), '../../', 'spec/fixtures', 'cicognara.marc.xml')
    xslpath = File.join(File.dirname(__FILE__), '../', 'xsl', 'catalogo-item-to-html.xsl')
    solr_server = Blacklight.connection_config[:url]
    solr = RSolr.connect(url: solr_server)
    solr.add(TEIIndexer.new(teipath, xslpath, marcpath).solr_docs)
    solr.commit
  end

  task :partials do
    desc 'Create partials at PARTIALSPATH from document at TEIPATH'
    teipath = ENV['TEIPATH'] || File.join(File.dirname(__FILE__), '../../', 'spec/fixtures', 'cicognara.tei.xml')
    partialspath = ENV['PARTIALSPATH'] || File.join(File.dirname(__FILE__), '../../', 'app/views/pages/catalogo/')
    xslpath = File.join(File.dirname(__FILE__), '../', 'xsl', 'partials.xsl')
    system(%(java -jar bin/saxon9he.jar -s:#{teipath} -xsl:#{xslpath} path_to_partials=#{partialspath}))
  end
end
