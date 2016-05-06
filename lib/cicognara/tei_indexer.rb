# tei_process.rb
require 'nokogiri'
require 'cicognara/catalogo_item'

class TEIIndexer
  attr_accessor :catalogo, :marc_collection, :items

  def initialize(pathtotei)
    @catalogo = File.open(pathtotei) { |f| Nokogiri::XML(f) }
    @items = []
    xpath = @catalogo.xpath("//tei:list[@type='catalog']/tei:item", 'tei' => 'http://www.tei-c.org/ns/1.0')
    xpath.each do |i|
      items.push(CatalogoItem.new(i))
    end
  end

  def solr_docs
    docs = []
    @items.each { |i| docs.push(i.solr_doc) }
    docs
  end
end
