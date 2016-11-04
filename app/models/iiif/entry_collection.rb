module IIIF
  class EntryCollection
    include Rails.application.routes.url_helpers
    attr_reader :entry
    delegate :to_json, to: :collection
    def initialize(entry)
      @entry = entry
    end

    private

    def collection
      @collection ||=
        IIIF::Presentation::Collection.new.tap do |c|
          c.label = entry.item_label
          c['@id'] = helper.manifest_entry_url(id: entry.n_value)
          c.collections = collections
        end
    end

    def collections
      entry.books.includes(:versions).map do |book|
        IIIF::BookCollection.new(book).collection
      end
    end

    def helper
      @helper ||= ::UrlGenerator.new
    end
  end
end
