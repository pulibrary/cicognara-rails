# catalogo_item.rb
class CatalogoItem
  attr_accessor :xml_element

  def initialize(xml_element, xsl, marc_collection)
    @xml_element = xml_element
    @xsl = xsl
    @marc_collection = marc_collection
  end

  def id
    ids = @xml_element.xpath('./@xml:id')
    ids.empty? ? 'NO_ID' : ids.first.value
  end

  def n
    ns = @xml_element.xpath('./@n')
    ns.empty? ? 'NO_N' : ns.first.value
  end

  def corresp
    c = @xml_element.xpath('./@corresp')
    c.empty? ? [] : c.first.value.split
  end

  def text
    @xml_element.to_str.gsub(/\s+/, ' ').strip
  end

  def html
    doc = Nokogiri::XML::Document.new
    doc.root = @xml_element
    @xsl.transform(doc).to_html
  end

  def solr_doc
    doc = { id: id, cico_s: n, description_display: html, description_t: text }
    unless corresp.empty?
      doc[:dclib_s] = corresp
      book_fields = get_marc_fields(corresp)
      doc[:title_display] = (book_fields['title_t'] || []).first
      doc.merge!(book_fields)
    end
    doc
  end

  private

  def get_marc_fields(dclib_nums)
    book_fields = {}
    dclib_nums.each do |num|
      marc = @marc_collection[num]
      book_fields.merge!(marc) { |_, oldval, newval| (newval + oldval).uniq } unless marc.nil?
    end
    # fields to ignore
    remove_display_fields(book_fields)

    # single-valued fields
    field_first_value(book_fields)

    book_fields['text'] = book_fields['text'].join(' ') unless book_fields['text'].nil?
    book_fields
  end

  def field_first_value(book)
    %w(marc_display title_sort author_sort
       pub_date).each { |f| book[f] = book[f].first unless book[f].nil? }
  end

  def remove_display_fields(book)
    %w(id format title_display author_display published_display
       title_addl_display title_added_entry_display title_series_display
       subject_display contents_display edition_display language_display
       related_name_display).each { |f| book.delete(f) }
  end
end
