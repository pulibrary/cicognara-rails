# catalogo_item.rb
class CatalogoItem
  attr_accessor :xml_element

  def initialize(xml_element, xsl, marc_collection, section_number, section_head)
    @xml_element = xml_element
    @xsl = xsl
    @marc_collection = marc_collection
    @section_number = section_number
    @section_head = section_head
  end

  def n
    ns = @xml_element.xpath('./@n')
    ns.empty? ? 'NO_N' : ns.first.value
  end

  def corresp
    c = @xml_element.xpath('./@corresp')
    c.empty? ? [] : c.first.value.split
  end

  def item_label
    title = @xml_element.xpath('./tei:label', tei: 'http://www.tei-c.org/ns/1.0')
    title.first.text.gsub(/\s+/, ' ').strip unless title.empty?
  end

  def item_titles
    titles = @xml_element.xpath('./tei:bibl/tei:title', tei: 'http://www.tei-c.org/ns/1.0')
    titles.map { |t| t.text.gsub(/\s+/, ' ').strip } unless titles.empty?
  end

  def item_authors
    authors = @xml_element.xpath('./tei:bibl/tei:author', tei: 'http://www.tei-c.org/ns/1.0')
    authors.map { |a| a.text.gsub(/\s+/, ' ').strip } unless authors.empty?
  end

  def item_pubs
    pubs = @xml_element.xpath('./tei:bibl/tei:pubPlace', tei: 'http://www.tei-c.org/ns/1.0')
    pubs.map { |p| p.text.gsub(/\s+/, ' ').strip } unless pubs.empty?
  end

  def item_dates
    dates = @xml_element.xpath('.//tei:date', tei: 'http://www.tei-c.org/ns/1.0')
    dates.map { |d| d.text.gsub(/\s+/, ' ').strip } unless dates.empty?
  end

  def item_notes
    notes = @xml_element.xpath('./tei:note', tei: 'http://www.tei-c.org/ns/1.0')
    notes.map { |n| n.text.gsub(/\s+/, ' ').strip } unless notes.empty?
  end

  def text
    @xml_element.to_str.gsub(/\s+/, ' ').strip
  end

  def solr_doc
    doc = doc_tei_fields
    unless corresp.empty?
      doc[:dclib_s] = corresp
      book_fields = get_marc_fields(corresp)
      doc.merge!(book_fields)
    end
    doc[:title_display] = solr_title_display(item_label || n, @section_number)
    doc
  end

  private

  def doc_tei_fields
    { id: n, cico_s: n, tei_description_unstem_search: text, tei_section_display: @section_number,
      tei_section_head_italian: @section_head, tei_title_txt: item_titles,
      tei_author_txt: item_authors, tei_pub_txt: item_pubs, tei_date_display: item_dates,
      tei_note_italian: item_notes }
  end

  def solr_title_display(label, section_number)
    "Catalogo Section #{section_number}, Item #{label.chomp('.')}"
  end

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
       related_name_display dclib_display).each { |f| book.delete(f) }
  end
end
