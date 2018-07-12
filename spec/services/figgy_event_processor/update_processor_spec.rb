require 'rails_helper'

describe FiggyEventProcessor::UpdateProcessor do
  subject(:update_processor) { described_class.new(event) }
  let(:id) { "62b69875-8ba0-420a-ba2c-2b46f2c801ca" }
  let(:manifest_url) { "http://localhost:3000/concern/scanned_resources/62b69875-8ba0-420a-ba2c-2b46f2c801ca/manifest" }
  let(:collection_slugs) { ["test-cicognara1-slug"] }
  let(:event) do
    {
      "id" => id,
      "event" => "UPDATED",
      "manifest_url" => manifest_url,
      "collection_slugs" => collection_slugs
    }
  end

  describe '#update_existing_resources' do

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
    let(:collection) { Collection.create(slug: "test-cicognara2-slug") }
    let(:existing_collection) { Collection.create(slug: collection_slugs.first) }
    let(:marc_file_path) { File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cicognara.marc.xml') }
    let(:marcxml) { File.open(marc_file_path) { |f| Nokogiri::XML(f) } }
    let(:book) do
      Book.create(
        digital_cico_number: "cico:m87",
        collections: [existing_collection],
        marcxml: marcxml
      )
    end
    let(:iiif_resource) { IIIF::Resource.create(url: manifest_url, book: book) }

    before do
      iiif_resource
      version
    end

    it 'updates IIIF::Resource objects in response to UPDATE messages' do
      update_processor.update_existing_resources

      updated_book = book.reload
      expect(updated_book.collections.length).to eq(1)
      expect(updated_book.collections).not_to include(collection)
      expect(updated_book.collections).to include(existing_collection)
    end
  end

  describe '#create_new_resources' do
    let(:iiif_resource) { IIIF::Resource.create(url: manifest_url, book: book) }

    let(:collection_slugs) { ["test-cicognara2-slug"] }
    let(:version) { Version.create(manifest: manifest_url) }
    let(:book) { Book.create(versions: [version]) }

    before do
      iiif_resource
    end

    it 'create new Collections objects in response to CREATE messages' do
      update_processor.create_new_resources

      new_collection = Collection.where(slug: collection_slugs.first)
      expect(new_collection).not_to be nil
    end
  end
end
