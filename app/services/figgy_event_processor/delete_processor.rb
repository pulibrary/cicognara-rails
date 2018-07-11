class FiggyEventProcessor
  class DeleteProcessor < Processor
    def process
      IIIFResource.where(url: manifest_url).each do |resource|
        docs = index.search(q: "spotlight_resource_id_ssim:#{RSolr.solr_escape(resource.url)}", fl: "id")
        docs["response"]["docs"].each do |doc|
          index.connection.delete_by_id doc["id"]
        end
        index.connection.commit
        resource.destroy
      end
      true
    end

    def index
      SolrDocument.index
    end
  end
end
