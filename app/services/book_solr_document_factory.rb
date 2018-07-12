class BookSolrDocumentFactory
  def initialize(model)
    @books = model
  end

  def indexer
    @indexer ||= Cicognara::BookIndexer.new(@books)
  end

  def to_solr
    indexer.to_solr.values
  end
end
