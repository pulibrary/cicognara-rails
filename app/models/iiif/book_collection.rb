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

    private

    def manifests
      book.versions.sort_by { |v| v.based_on_original ? 1 : 0 }.map do |v|
        IIIF::Presentation::Manifest.new.tap do |c|
          c['@id'] = v.manifest
          c['label'] = v.label
        end
      end
    end

    def helper
      @helper ||= UrlGenerator.new
    end
  end
end
