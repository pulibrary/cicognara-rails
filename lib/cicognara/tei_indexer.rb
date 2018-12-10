# tei_indexer.rb
require 'nokogiri'
require 'cicognara/catalogo_item'
require 'cicognara/with_book_cache'
require 'cicognara/bulk_entry_indexer'
require 'cicognara/section'
require './app/models/marc_indexer'

module Cicognara
  class TEIIndexer
    attr_accessor :catalogo, :marc, :books, :entries

    def initialize(pathtotei, pathtomarc)
      @catalogo = File.open(pathtotei) { |f| Nokogiri::XML(f) }
      @marc_file_path = pathtomarc
      @marc = File.open(@marc_file_path) { |f| Nokogiri::XML(f) }
      Entry.transaction do
        build_entries
        entries.each(&:save)
        books.each(&:save)
      end
    end

    def solr_docs
      @solr_docs ||= bulk_entry_indexer.book_documents + bulk_entry_indexer.entry_documents
    end

    def entries
      @entries ||= sections.flat_map { |section| process_section(section) }
    end

    def books
      @books ||= process_marc_records
    end

    def grouped_books
      return @grouped_books unless @grouped_books.nil?

      @grouped_books = {}

      books.each do |book|
        book.digital_cico_numbers.each do |dlc_number|
          @grouped_books[dlc_number] = book
        end
      end

      @grouped_books
    end

    private

    def build_entries
      entries.each do |entry|
        next unless entry.corresp.present?
        entry.books = []
        entry.corresp.each do |book_id|
          entry.books << grouped_books[book_id] if grouped_books[book_id]
        end
      end
    end

    def bulk_entry_indexer
      @bulk_entry_indexer ||= BulkEntryIndexer.new(entries)
    end

    def sections
      @sections ||= catalogo.xpath("//tei:div[@type='section']", 'tei' => 'http://www.tei-c.org/ns/1.0')
    end

    def process_section(section)
      section = Section.new(section)
      existing_entries = Entry.where(entry_id: section.ids).group_by(&:entry_id)
      section.items.map do |i|
        entry = entry_fetch(i.attributes['id'].value, existing_entries)
        assign_section(entry, section)
        entry.tei = i
        entry.tei_will_change!
        entry.n_value = entry.n
        entry
      end
    end

    def entry_fetch(id, existing_entries)
      Array(existing_entries[id]).first || Entry.new(entry_id: id)
    end

    def assign_section(entry, section)
      entry.section_number = section.section_number
      entry.section_head = section.section_head
      entry.section_display = section.section_display
    end

    # This needs to reconcile the DCL numbers
    # Currently, it is assumed that each MarcRecord only has one DCL number
    def process_marc_records
      books = []

      marc_records.each do |marc_record|
        book = Book.find_or_create_by(marc_record_id: marc_record.id)
        book.marc_record = marc_record
        book.save
        books << book
      end

      books
    end

    def marc_file_uri_base
      ['file://', Pathname.new(@marc_file_path)].join
    end

    def marc_xpath
      '//marc:record'
    end

    def marc_file_uri(idx)
      [marc_file_uri_base, marc_xpath, "[#{idx}]"].join
    end

    def marc_elements
      marc.xpath(marc_xpath, marc: 'http://www.loc.gov/MARC21/slim')
    end

    def marc_records
      marc_elements.map.with_index { |_element, idx| MarcRecord.resolve(marc_file_uri(idx)) }
    end
  end
end
