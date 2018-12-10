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

    def books(*args)
      super.map do |book|
        solr_documents = []
        solr_documents << book_records[book.marc_record.file_uri_digest] if book_records.key?(book.marc_record.file_uri_digest)
        BookWithCachedSolr.new(book, solr_documents)
      end
    end

    class BookWithCachedSolr < SimpleDelegator
      attr_reader :book, :solr_documents
      def initialize(book, solr_documents)
        super(book)
        @solr_documents = solr_documents
      end

      def to_solr
        return extra_solr if solr_documents.empty?
        Array.wrap(solr_documents).first.merge(extra_solr)
      end
    end
  end
end
