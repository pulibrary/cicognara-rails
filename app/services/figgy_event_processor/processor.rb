class FiggyEventProcessor
  class Processor
    attr_reader :event

    def initialize(event)
      @event = event
    end

    private

      def manifest_url
        event["manifest_url"]
      end

      def collection_slugs
        event["collection_slugs"]
      end

      def event_type
        event["event"]
      end

      def add_to_index(resource)
        documents = SolrDocumentFactory.build(resource)
        indexer.add(documents)
      end

      def delete_from_index(resource)
        documents = SolrDocumentFactory.build(resource)
        indexer.delete(documents)
      end

      def indexer
        @indexer ||= SolrIndexer.new
      end
  end
end
