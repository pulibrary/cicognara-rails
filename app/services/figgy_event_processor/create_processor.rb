class FiggyEventProcessor
  class CreateProcessor < Processor
    def process
      resource = IIIFResource.new(url: manifest_url)
      resource.save_and_index
    end
  end
end
