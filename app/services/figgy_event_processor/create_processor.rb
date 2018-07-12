class FiggyEventProcessor
  class CreateProcessor < Processor
    def process
      resource = IIIF::Resource.new(url: manifest_url)
      resource.save
      add_to_index(resource.book)
    end
  end
end
