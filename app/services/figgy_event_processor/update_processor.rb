class FiggyEventProcessor
  class UpdateProcessor < Processor
    def process
      update_existing_resources
      create_new_resources
      true
    end

    def update_existing_resources
      existing_slugs.each do |slug|

        Version.where(manifest: manifest_url).each do |version|
          next unless version.book

          iiif_resource = IIIF::Resource.first_or_create(url: manifest_url)

          Collection.where(slug: slug).each do |existing_collection|

            version.book.collections << existing_collection unless version.book.collections.include?(existing_collection)
            version.book.iiif_resource = iiif_resource
            version.book.save
            add_to_index(version.book)
          end
        end
      end
    end

    def create_new_resources
      new_collection_slugs.each do |slug|
        Version.where(manifest: manifest_url).each do |version|
          next unless version.book

          iiif_resource = IIIF::Resource.first_or_create(url: manifest_url)
          new_collection = Collection.create(slug: slug)

          version.book.collections << new_collection
          version.book.iiif_resource = iiif_resource
          version.book.save
          add_to_index(version.book)
        end
      end
    end

    private

      def new_collection_slugs
        collection_slugs - existing_slugs
      end

      def deleted_slugs
        existing_slugs - collection_slugs
      end

      def existing_slugs
        Collection.all.map(&:slug)
      end
  end
end
