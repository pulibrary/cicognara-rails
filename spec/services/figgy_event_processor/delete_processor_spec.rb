require 'rails_helper'

describe FiggyEventProcessor::DeleteProcessor do
  subject(:delete_processor) { described_class.new(event) }
  let(:id) { "62b69875-8ba0-420a-ba2c-2b46f2c801ca" }
  let(:manifest_url) { "http://localhost:3000/concern/scanned_resources/62b69875-8ba0-420a-ba2c-2b46f2c801ca/manifest" }
  let(:collection_slugs) { ["test-cicognara1-slug"] }
  let(:event) do
    {
      "id" => id,
      "event" => "DELETED",
      "manifest_url" => manifest_url,
      "collection_slugs" => collection_slugs
    }
  end

  describe '#process' do
    let(:label) { "Test Title, The" }
    let(:contributing_library) { ContributingLibrary.create(label: "Contributor 1", uri: "http://localhost.localdomain") }
    let(:owner_system_number) { "1234567a" }
    let(:version) do
      Version.create(
        label: label,
        contributing_library: contributing_library,
        owner_system_number: owner_system_number,
        manifest: manifest_url,
        book: book,
        based_on_original: true,
        rights: 'https://creativecommons.org/publicdomain/mark/1.0/',
        owner_system_number: 'abc123'
      )
    end
    let(:collection) { Collection.create(slug: collection_slugs.first) }
    let(:marc_file_path) { File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cicognara.marc.xml') }
    let(:marcxml) { File.open(marc_file_path) { |f| Nokogiri::XML(f) } }
    let(:book) do
      Book.create(
        digital_cico_number: "cico:m87",
        collections: [collection],
        marcxml: marcxml
      )
    end
    let(:iiif_resource) { IIIF::Resource.create(url: manifest_url, book: book) }

    before do
      version
      iiif_resource
    end

    it 'deletes IIIF::Resource objects' do
      expect(book.iiif_resource).to eq iiif_resource

      delete_processor.process

      updated_book = book.reload
      expect(updated_book.iiif_resource).to be_nil
    end
  end
end
