class SolrDocumentFactory
  def self.build(model)
    indexer_klass = klass(model)
    indexer = indexer_klass.new(model)
    indexer.to_solr
  end

  def self.klass(model)
    @indexer_klass ||= case model
      when Book
        BookSolrDocumentFactory
      else
        BaseSolrDocumentFactory
      end
  end
end
