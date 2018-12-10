module Cicognara
  class BulkEntryIndexer
    attr_reader :entries
    def initialize(entries)
      @entries = entries
    end

    def book_documents
      entries_with_cached_book_solrs.flat_map(&:books).flat_map(&:to_solr)
    end

    def books
      all_books = entries.flat_map(&:books)
      all_books.uniq(&:id)
    end

    def entry_documents
      entries_with_cached_book_solrs.map(&:to_solr)
    end

    def entries_with_cached_book_solrs
      entries.map do |entry|
        WithBookCache.new(entry, unmerged_book_documents)
      end
    end

    private

    def unmerged_book_documents
      @unmerged_book_documents ||= BookIndexer.new(books).to_solr
    end
  end
end
