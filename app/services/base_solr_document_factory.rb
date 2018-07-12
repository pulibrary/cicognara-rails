class BaseSolrDocumentFactory
  attr_reader :model

  def initialize(model)
    @model = model
  end

  delegate :to_solr, to: :model
end
