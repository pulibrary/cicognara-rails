# tei_indexer.rb
require 'nokogiri'
require 'cicognara/catalogo_item'
require 'cicognara/with_book_cache'
require 'cicognara/bulk_entry_indexer'
require 'cicognara/section'
require 'cicognara/marc_record'
require './app/models/marc_indexer'

module Cicognara
  class TEIIndexer
    attr_accessor :catalogo, :marc, :books, :entries

    def initialize(pathtotei, pathtomarc)
      @catalogo = File.open(pathtotei) { |f| Nokogiri::XML(f) }
      @marc = File.open(pathtomarc) { |f| Nokogiri::XML(f) }
      build_entries
      entries.each(&:save)
      books.each(&:save)
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
      books.group_by(&:digital_cico_number)
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
      section.items.map do |i|
        entry = Entry.find_or_initialize_by(entry_id: i.attribute('id').value, section_number: section.section_number, section_head: section.section_head, section_display: section.section_display)
        entry.tei = i
        entry.tei_will_change!
        entry.n_value = entry.n
        entry
      end
    end

    def process_marc_records
      marc_records.map do |record|
        record = MarcRecord.new(record)
        book = Book.find_or_initialize_by(digital_cico_number: record.book_id)
        book.marcxml = record.source
        book.marcxml_will_change!
        book
      end
    end

    def marc_records
      marc.xpath('.//marc:record', marc: 'http://www.loc.gov/MARC21/slim')
    end
  end
end
