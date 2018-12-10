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

    def initialize(pathtotei, pathtomarc, index)
      @catalogo = File.open(pathtotei) { |f| Nokogiri::XML(f) }
      @marc_file_path = pathtomarc
      @index = index
      @marc = File.open(@marc_file_path) { |f| Nokogiri::XML(f) }
      Entry.transaction do
        build_entry_associations
        entries.each(&:save)
        books.each(&:save)
      end
    end

    def book_documents
      return @book_documents unless @book_documents.nil?
      indexer = BookIndex.new(books)
      @book_documents = indexer.to_solr
    end

    def index
      Rails.logger.info 'Indexing the Solr Documents for Entry and Book objects'
      bulk_entry_indexer.index
    end

    # This should be deprecated, as it is not performant
    def solr_docs
      Rails.logger.info 'Generating the Solr Documents for Entry and Book objects'
      @solr_docs ||= bulk_entry_indexer.documents
    end

    # Constructs the Entry Models and saves them
    def entries
      Rails.logger.info 'Loading the Entry objects from the TEI Documents'
      @entries ||= sections.flat_map { |section| process_section(section) }
    end

    def save_entries!
      entries.each(&:save).each(&:reload)
    end

    def books
      Rails.logger.info 'Loading the Book objects from the MARC Records'
      @books ||= process_marc_records
    end

    def save_books!
      books.each(&:save)
    end

    # Groups Book Models by DLC numbers
    # Each DLC number may map to one or many Book
    # @return [Hash]
    def grouped_books
      return @grouped_books unless @grouped_books.nil?

      @grouped_books = {}
      books.each do |book|
        book.digital_cico_numbers.each do |dlc_number|
          group = @grouped_books.key?(dlc_number) ? @grouped_books[dlc_number] + [book] : [book]
          @grouped_books[dlc_number] = group
        end
      end

      @grouped_books
    end

    private

      # Iterates through each Entry Model and links them to one or many Books
      def build_entry_associations
        entries.each do |entry|
          next unless entry.corresp.present?
          entry.books = []
          entry.corresp.each do |book_id|
            entry.books += grouped_books[book_id] if grouped_books[book_id]
          end
          entry.save
          entry.reload
        end
        @entries
      end

      def bulk_entry_indexer
        @bulk_entry_indexer ||= BulkEntryIndexer.new(entries, @index)
      end

      def sections
        @sections ||= catalogo.xpath("//tei:div[@type='section']", 'tei' => 'http://www.tei-c.org/ns/1.0')
      end

      # Construct a number of Entry Models from a Section Object
      # @return [Array<Entry>]
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

      def marc_xpath
        '//marc:record'
      end

      def marc_namespaces
        {
          'marc' => 'http://www.loc.gov/MARC21/slim'
        }
      end

      def marc_records
        return @marc_records unless @marc_records.nil?
        models = MarcRecord.resolve_from_xpath(file_path: @marc_file_path, xpath: marc_xpath, namespaces: marc_namespaces)
        models.each(&:save)
        @marc_records = models
      end

      # Iterates through the MarcRecord models saves a Book model for each
      # @return [Array<Book>]
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
  end
end
