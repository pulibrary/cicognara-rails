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
      @grouped_books ||= books.group_by(&:digital_cico_number)
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

    def book_fetch(key, existing_books)
      Array(existing_books[key]).first || Book.new(digital_cico_number: key)
    end

    def process_marc_records
      records = marc_records.map { |x| MarcRecord.new(x) }.group_by(&:book_id)
      existing_books = Book.includes(:versions, :contributing_libraries).where(digital_cico_number: records.keys).group_by(&:digital_cico_number)
      records.map do |key, inner_records|
        book = book_fetch(key, existing_books)
        book.marcxml = inner_records.first.source
        book.marcxml_will_change!
        book
      end
    end

    def marc_records
      marc.xpath('.//marc:record', marc: 'http://www.loc.gov/MARC21/slim')
    end
  end
end
