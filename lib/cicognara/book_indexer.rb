module Cicognara
  class BookIndexer
    attr_reader :books
    def initialize(books)
      @books = Array(books)
    end

    def to_solr
      @to_solr ||= marc_solr.present? ? marc_solr : blank_records
    end

    private

    def marc_solr
      return @marc_solr if @marc_solr

      marc_records.each do |marc_record|
        Tempfile.open('book_marc') do |f|
          f.write(marc_collection(marc_record.source))
          f.close
          indexer.process(f.path, marc_record.file_uri)
        end
      end

      # binding.pry
      @marc_solr = indexer.writer.all_records unless marc_records.empty?
    end

    def blank_records
      books.each_with_object({}) do |book, hsh|
        hsh[book.digital_cico_number] = { 'id' => book.digital_cico_number }
      end
    end

    def indexer
      @indexer ||=
        MarcIndexer.new.tap do |i|
          i.writer = SolrWriterAccumulator.new(i.settings)
        end
    end

    def marc_documents
      books.map(&:marcxml).map(&:clone)
    end

    def marc_records
      books.map(&:marc_record).compact
    end

    def marc_collection(document)
      collection = Nokogiri::XML('<collection></collection>')
      return unless document.root.present?
      collection.root << document.root
      collection.to_xml
    end
  end
end
