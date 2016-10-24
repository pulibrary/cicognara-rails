module Cicognara
  ##
  # Used when all the appropriate solr records for the books attached to events
  # were generated at once, as in a bulk ingest from a single MARC XML file.
  class WithBookCache < SimpleDelegator
    attr_reader :entry, :book_records
    def initialize(entry, book_records)
      @entry = entry
      @book_records = book_records
      super(entry)
    end

    def to_solr
      CatalogoItem.new(self).solr_doc
    end

    def books
      super.map do |book|
        BookWithCachedSolr.new(book, book_records[book.digital_cico_number])
      end
    end

    class BookWithCachedSolr < SimpleDelegator
      attr_reader :book, :solr_documents
      def initialize(book, solr_documents)
        super(book)
        @solr_documents = solr_documents
      end

      def to_solr
        Array.wrap(solr_documents).first
      end
    end
  end
end
