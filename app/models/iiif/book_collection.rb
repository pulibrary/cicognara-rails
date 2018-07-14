module IIIF
  class BookCollection
    include Rails.application.routes.url_helpers

    attr_reader :book

    delegate :to_json, to: :collection

    def initialize(book)
      @book = book
    end

    def collection
      @collection ||=
        IIIF::Presentation::Collection.new.tap do |c|
          solr = book.to_solr
          c.label = Array(solr['title_display']).first
          c['@id'] = helper.manifest_book_url(id: book.id)
          c.manifests = manifests
        end
    end

    def self.build_manifest(iiif_record, index = 0)
      IIIF::Presentation::Manifest.new.tap do |manifest|
        label = "Version #{index + 1}"
        manifest['@id'] = iiif_record.uri
        manifest['label'] = label
      end
    end

    private

      def manifests
        book.versions.each_with_index.map { |version, index| IIIF::Manifest.build_presentation(version.iiif_manifest) }
      end

      def helper
        @helper ||= UrlGenerator.new
      end
  end
end
