# tei_indexer.rb
require 'nokogiri'
require 'cicognara/catalogo_item'
require './app/models/marc_indexer'

class TEIIndexer
  attr_accessor :catalogo, :items, :marc_collection

  def initialize(pathtotei, pathtoxsl, pathtomarc)
    @catalogo = File.open(pathtotei) { |f| Nokogiri::XML(f) }
    @items = []
    @marc_collection = prepare_marc(pathtomarc)
    xpath = @catalogo.xpath("//tei:list[@type='catalog']/tei:item", 'tei' => 'http://www.tei-c.org/ns/1.0')
    xsl = File.open(pathtoxsl) { |f| Nokogiri::XSLT(f) }
    xpath.each do |i|
      items.push(CatalogoItem.new(i, xsl, @marc_collection))
    end
  end

  def solr_docs
    docs = []
    @items.each { |i| docs.push(i.solr_doc) }
    docs
  end

  private

  def prepare_marc(pathtomarc)
    indexer = MarcIndexer.new
    indexer.writer = SolrWriterAccumulator.new(indexer.settings)
    indexer.process(pathtomarc)
    indexer.writer.all_records
  end
end
