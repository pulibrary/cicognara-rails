module Cicognara
  class EntryIndexer
    attr_reader :entry
    # Constructor
    # @param entry [Entry]
    # @param index [RSolr::Client]
    # @param cache [Hash]
    # @param books_cache [Hash]
    def initialize(entry, index, cache, books_cache)
      @entry = entry
      @index = index
      @cache = cache
      @books_cache = books_cache
    end

    def books
      @entry.books
    end

    def books_cache_key
      return if books.empty?
      books.map(&:id).sort.map(&:to_s).join('_')
    end

    def book_indexer
      BookIndexer.new(@entry.books)
    end

    def book_documents
      return {} if books.empty?

      @book_documents = book_indexer.to_solr
      @books_cache[books_cache_key] = @book_documents
      @books_cache[books_cache_key]
    end

    def book_document_values
      book_documents.values.compact
    end

    def entry_cache_key
      entry.id.to_s
    end

    def cache
      @cache[entry_cache_key] = WithBookCache.new(@entry, book_documents)
      @cache[entry_cache_key]
    end

    def documents
      @documents ||= cache.to_solr
    end

    def index
      @index.add(documents)
      @index.commit
    end
  end

  class BulkEntryIndexer
    attr_reader :entries
    def initialize(entries, index)
      @entries = entries
      @index = index
      @entries_cache = {}
      @books_cache = {}
    end

    def entry_indexers
      @entry_indexers ||= @entries.map { |entry| EntryIndexer.new(entry, @index, @entries_cache, @books_cache) }
    end

    def child_indexers
      @child_indexers ||= entry_indexers
    end

    def documents
      return @documents unless @documents.nil?

      @documents = []
      child_indexers.each do |indexer|
        indexer.documents
        indexer.book_document_values
        @documents += [indexer.documents] + indexer.book_document_values
      end
      @documents
    end

    def index
      child_indexers.each do |indexer|
        Rails.logger.info "Indexing for #{indexer.entry.item_titles.join(',')}"
        indexer.index
      end
    end

    def cached_books
      entries_with_cached_book_solrs.flat_map(&:books)
    end

    def book_documents
      cached_books.flat_map(&:to_solr)
    end

    def books
      models = entries.flat_map(&:books)
      models.uniq(&:id)
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
        # This is extremely expensive to generate
        @unmerged_book_documents ||= BookIndexer.new(books).to_solr
      end
  end
end
