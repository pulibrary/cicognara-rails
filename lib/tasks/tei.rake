require 'cicognara/tei_indexer'

namespace :tei do
  desc 'index solr documents from path to document at TEIPATH.'
  task :index do
    teipath = ENV['TEIPATH'] || File.join(File.dirname(__FILE__), '../../', 'spec/fixtures', 'cicognara.tei.xml')
    solr_server = Blacklight.connection_config[:url]
    solr = RSolr.connect(url: solr_server)
    solr.add(TEIIndexer.new(teipath).solr_docs)
    solr.commit
  end
end
