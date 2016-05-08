require 'cicognara/tei_indexer'

namespace :tei do
  desc 'index solr documents from path to document at TEIPATH and MARCPATH.'
  task :index do
    teipath = ENV['TEIPATH'] || File.join(File.dirname(__FILE__), '../../', 'spec/fixtures', 'cicognara.tei.xml')
    marcpath = ENV['MARCPATH'] || File.join(File.dirname(__FILE__), '../../', 'spec/fixtures', 'cicognara.marc.xml')
    xslpath = ENV['XSLPATH'] || File.join(File.dirname(__FILE__), '../', 'xsl', 'catalogo-item-to-html.xsl')
    solr_server = Blacklight.connection_config[:url]
    solr = RSolr.connect(url: solr_server)
    solr.add(TEIIndexer.new(teipath, xslpath, marcpath).solr_docs)
    solr.commit
  end
end
