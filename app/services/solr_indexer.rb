class SolrIndexer
  def solr_url
    Blacklight.connection_config[:url]
  end

  def solr
    @solr ||= RSolr.connect(url: solr_url)
  end

  delegate :commit, to: :solr

  def delete_all
    solr.delete_by_query('*:*')
    commit
  end

  def add(documents)
    solr.add(documents)
    commit
  end

  def delete(documents)
    documents.each do |doc|
      solr.delete_by_id(doc["id"])
    end
    commit
  end
end
