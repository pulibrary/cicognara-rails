# catalogo_item.rb
module Cicognara
  class CatalogoItem
    attr_accessor :entry
    delegate :n, :text, :item_authors, :item_pubs, :item_dates, :item_notes, :item_titles, :item_label, :section_display, :section_head, :section_number, :books, to: :entry

    def initialize(entry)
      @entry = entry
    end

    def solr_doc
      doc = doc_tei_fields
      unless books.empty? && corresp.empty?
        doc[:dclib_s] = corresp
        book_fields = marc_fields
        doc.merge!(book_fields)
      end
      doc[:title_display] = solr_title_display(item_label || n)
      doc['digitized_version_available_facet'] = resolve_avail(doc['digitized_version_available_facet'])
      doc
    end

    private

    def resolve_avail(arr)
      (arr || []).include?('Yes') ? 'Yes' : 'No'
    end

    def book_digital_cico_numbers
      books.map(&:digital_cico_number).compact
    end

    def corresp
      return nil if entry.corresp.empty? && book_digital_cico_numbers.empty?
      (entry.corresp + book_digital_cico_numbers).uniq
    end

    def doc_tei_fields
      { id: n, alt_id: n, cico_s: n, cico_sort: n, tei_description_unstem_search: text, tei_section_display: section_display,
        tei_section_head_italian: section_head, tei_section_number_display: section_number,
        tei_author_txt: item_authors, tei_pub_txt: item_pubs, tei_date_display: item_dates,
        tei_note_italian: item_notes, tei_title_txt: item_titles, tei_section_facet: section_display }
    end

    def solr_title_display(label)
      "Catalogo Item #{label.chomp('.')}"
    end

    def marc_fields
      book_fields = {}
      books.each do |book|
        book_doc = book.to_solr
        book_fields.merge!(book_doc) { |_, oldval, newval| (Array.wrap(newval) + Array.wrap(oldval)).uniq } unless book_doc.nil?
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
      %w(id format title_display author_display published_display title_addl_display
         title_added_entry_display title_series_display
         contents_display edition_display language_display
         related_name_display dclib_display).each { |f| book.delete(f) }
    end
  end
end
