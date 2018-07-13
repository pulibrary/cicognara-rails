class FiggyEventProcessor
  class CreateProcessor < Processor
    def process
      iiif_resource = IIIF::Resource.first_or_create(url: manifest_url)

      collection_slugs.each do |slug|
        new_collection = Collection.first_or_create(slug: slug)

        Version.where(manifest: manifest_url).each do |version|
          version.book.collections << new_collection unless version.book.collections.include?(new_collection)
          version.book.iiif_resource = iiif_resource
          version.book.save
          add_to_index(version.book)
        end
      end

      true
    end
  end
end
