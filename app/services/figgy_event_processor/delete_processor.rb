class FiggyEventProcessor
  class DeleteProcessor < Processor
    def process
      IIIF::Resource.where(url: manifest_url).each do |resource|
        docs = index.search(q: "manifests_s:#{RSolr.solr_escape(resource.url)}", fl: "id")
        docs["response"]["docs"].each do |doc|
          index.connection.delete_by_id doc["id"]
        end
        index.connection.commit
        delete_from_index(resource.book)
        IIIF::Resource.destroy(resource.id)
      end
      true
    end

    def index
      SolrDocument.index
    end
  end
end
