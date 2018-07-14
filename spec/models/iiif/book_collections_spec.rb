require 'rails_helper'

describe IIIF::BookCollection do
  subject(:book_collection) { described_class.new(book) }

  let(:marc_path) { File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cicognara.marc.xml') }
  let(:marcxml) { File.open(marc_path) { |f| Nokogiri::XML(f) } }
  let(:file_uri) { "file:///test.mrx//marc:record[0]" }
  let(:marc_record) { MarcRecord.create(source: marcxml, file_uri: file_uri) }
  let(:book) { Book.create(volumes: [volume], marc_record: marc_record) }

  let(:contributing_library) { ContributingLibrary.create(label: 'Example Library', uri: 'http://www.example.org') }
  let(:manifest_uri) { "http://example.org/1.json" }
  let(:manifest_label) { "Version 1" }
  let(:iiif_manifest) { IIIF::Manifest.create(uri: manifest_uri, label: manifest_label) }
  let(:version) do
    Version.create(
      contributing_library: contributing_library,
      label: 'version 2',
      based_on_original: true,
      owner_system_number: '1234',
      rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
      iiif_manifest: iiif_manifest
    )
  end
  let(:digital_cico_number) { 'xyz' }
  let(:volume) {
    Volume.new(digital_cico_number: digital_cico_number, versions: [version])
  }

  describe "#collection" do
    it "constructs IIIF::Presentation::Collection objects for collections" do
      expect(book_collection.collection).to be_a IIIF::Presentation::Collection

      book_collection.collection['@type']

      expect(book_collection.collection).to include("@id")
      expect(book_collection.collection).to include("@type")
      expect(book_collection.collection).to include("label")
      expect(book_collection.collection).to include("manifests")

      expect(book_collection.collection["@id"]).to eq("http://test.org/books/1/manifest")
      expect(book_collection.collection["@type"]).to eq("sc:Collection")
      expect(book_collection.collection["label"]).to eq("Commentario inedito di Lorenzo Ghiberti estratto da manoscritti della Biblioteca Magliabecchiana")
      expect(book_collection.collection["manifests"]).not_to be_empty

      expect(book_collection.collection["manifests"].first).to be_a IIIF::Presentation::Manifest
      expect(book_collection.collection["manifests"].first["@id"]).to eq(manifest_uri)
      expect(book_collection.collection["manifests"].first["label"]).to eq(manifest_label)
    end
  end

  describe "#to_json" do
    subject(:json) { book_collection.to_json }
    it "generates a JSON Object for the IIIF Manifest" do

      expect(json).not_to be_empty
      expect { JSON.parse(json) }.not_to raise_error(JSON::ParserError)

      values = JSON.parse(json)
      expect(values).to include "@id"
      expect(values).to include "@context"
      expect(values).to include "@type"
      expect(values).to include "label"
      expect(values).to include "manifests"

      expect(values["@id"]).to eq("http://test.org/books/1/manifest")
      expect(values["@context"]).to eq("http://iiif.io/api/presentation/2/context.json")
      expect(values["@type"]).to eq("sc:Collection")
      expect(values["label"]).to eq("Commentario inedito di Lorenzo Ghiberti estratto da manoscritti della Biblioteca Magliabecchiana")
      expect(values["manifests"]).not_to be_empty
      expect(values["manifests"].first).to be_a Hash
      expect(values["manifests"].first["@id"]).to eq("http://example.org/1.json")
      expect(values["manifests"].first["@type"]).to eq("sc:Manifest")
      expect(values["manifests"].first["label"]).to eq("Version 1")
    end
  end
end
