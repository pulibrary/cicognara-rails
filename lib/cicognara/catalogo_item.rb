# catalogo_item.rb
class CatalogoItem
  attr_accessor :xml_element

  def initialize(xml_element)
    @xml_element = xml_element
  end

  def id
    @xml_element.xpath('./@xml:id').first.value
  end

  def n
    @xml_element.xpath('./@n').first.value
  end

  def corresp
    c = @xml_element.xpath('./@corresp')
    c.empty? ? [] : c.first.value.split
  end

  def text
    @xml_element.to_str.gsub(/\s+/, ' ').strip
  end

  def solr_doc
    doc = { id: id, cico_s: n, description_t: text }
    doc[:dclib_s] = corresp unless corresp.empty?
    doc
  end
end
