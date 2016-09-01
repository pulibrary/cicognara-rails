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
    @xsl = File.open(pathtoxsl) { |f| Nokogiri::XSLT(f) }
    sections = @catalogo.xpath("//tei:div[@type='section']", 'tei' => 'http://www.tei-c.org/ns/1.0')
    sections.each { |section| process_section(section) }
  end

  def solr_docs
    docs = []
    @items.each { |i| docs.push(i.solr_doc) }
    docs
  end

  private

  def process_section(section)
    section_number = section.xpath('@n')
    xpath = section.xpath(".//tei:list[@type='catalog']/tei:item", 'tei' => 'http://www.tei-c.org/ns/1.0')
    xpath.each do |i|
      items.push(CatalogoItem.new(i, @xsl, @marc_collection, section_number))
    end
  end

  def prepare_marc(pathtomarc)
    indexer = MarcIndexer.new
    indexer.writer = SolrWriterAccumulator.new(indexer.settings)
    indexer.process(pathtomarc)
    indexer.writer.all_records
  end
end
