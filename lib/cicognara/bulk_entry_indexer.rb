module Cicognara
  class BulkEntryIndexer
    attr_reader :entries
    def initialize(entries)
      @entries = entries
    end

    def book_documents
      @book_documents ||= BookIndexer.new(books).to_solr
    end

    def books
      entries.flat_map(&:books)
    end

    def entry_documents
      entries_with_cached_book_solrs.map(&:to_solr)
    end

    def entries_with_cached_book_solrs
      entries.map do |entry|
        WithBookCache.new(entry, book_documents)
      end
    end
  end
end
