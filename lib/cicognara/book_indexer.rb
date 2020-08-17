module Cicognara
  class BookIndexer
    attr_reader :books
    def initialize(books)
      @books = Array(books)
    end

    def to_solr
      @to_solr ||= marc_solr.presence || blank_records
    end

    private

    def marc_solr
      @marc_solr ||=
        Tempfile.open('book_marc') do |f|
          f.write combined_marc
          f.close
          indexer.process(f.path)
          indexer.writer.all_records
        end
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

    def all_marc
      books.map(&:marcxml).map(&:clone)
    end

    def combined_marc
      builder = Nokogiri::XML('<collection></collection>')
      all_marc.each do |record|
        next unless record.root.present?

        builder.root << record.root
      end
      builder.to_xml
    end
  end
end
