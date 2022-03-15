# catalogo_item.rb
module Cicognara
  class CatalogoItem
    attr_accessor :entry
    delegate :n, :text, :item_authors, :item_pubs, :item_dates, :item_notes, :item_titles, :item_label, :section_display, :section_head, :section_number, :books, to: :entry

    def initialize(entry)
      @entry = entry
    end

    # rubocop:disable Metrics/AbcSize
    def solr_doc
      doc = doc_tei_fields
      unless books.empty? && corresp.empty?
        doc[:dclib_s] = corresp
        book_fields = marc_fields
        doc.merge!(book_fields)
      end
      doc[:title_display] = solr_title_display(item_label || n)
      doc['digitized_version_available_facet'] = resolve_avail(doc['digitized_version_available_facet'])
      doc['pub_date'] = resolve_pub_date(doc)
      doc
    end
    # rubocop:enable Metrics/AbcSize

    private

    def resolve_avail(arr)
      arr = (arr || []).flatten.uniq
      arr.length == 1 ? arr : arr.reject { |v| v == 'None' }
    end

    def corresp
      (entry.corresp + books.map(&:digital_cico_number)).uniq
    end

    # rubocop:disable Metrics/AbcSize
    def doc_tei_fields
      # A better version of `cico_sort``.
      #
      # This new field pads the value so that it sorts correctly, stores is as a string
      # (so we can fetch it and confirm its value), and it is not subject to Solr's
      # built-in 'alphaOnly' transformations that apply to `_sort` fields.
      cico_sort_s = n.rjust(6, '0')

      { id: n, alt_id: n, cico_s: n, cico_sort: n, tei_description_unstem_search: text, tei_section_display: section_display,
        tei_section_head_italian: section_head, tei_section_number_display: section_number,
        tei_author_txt: item_authors, tei_pub_txt: item_pubs, tei_date_display: item_dates,
        tei_note_italian: item_notes, tei_title_txt: item_titles, tei_section_facet: section_display,
        cico_sort_s: cico_sort_s }
    end
    # rubocop:enable Metrics/AbcSize

    def solr_title_display(label)
      "Catalogo Item #{label.chomp('.')}"
    end

    def marc_fields
      book_fields = {}
      books.each do |book|
        book_doc = book.to_solr
        book_fields.merge!(book_doc) { |_, oldval, newval| (newval + oldval).uniq } unless book_doc.nil?
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

    # Decides what publication year to use (the one from the MARC data or the one from TEI)
    def resolve_pub_date(doc)
      tei_year = single_tei_year(doc[:tei_date_display] || [])
      if tei_year.nil?
        # Use whatever value we had before (could be nil)
        doc['pub_date']
      else
        # Use the year in the TEI data rather than the one in the MARC data.
        # These values are usually identical but not always. It makes sense to use store in Solr the
        # year from the TEI data because that is the value that we _display_ to the user and therefore
        # we want to make sure Solr sorts by this year (rather than the year in MARC that is not
        # displayed to the user).
        tei_year
      end
    end

    # Extracts a single year from an array of TEI display dates.
    # Notice that each value in the array is a string with maybe a year somewhere
    # (e.g. "1891" or "A. 1541,", or "1813 al 1818,") and the code makes its best
    # effort to extract the earliest possible year.
    def single_tei_year(tei_date_display)
      years = tei_date_display.map do |date|
        year_match = date.match(/\d\d\d\d/)&.to_s
        year_match ? year_match.to_i : nil
      end
      years.compact.min
    end
  end
end
