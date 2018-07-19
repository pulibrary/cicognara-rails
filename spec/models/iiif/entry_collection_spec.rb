require 'rails_helper'

RSpec.describe IIIF::EntryCollection do
  subject(:entry_collection) { described_class.new(entry) }
  let(:digital_cico_number) { 'xyz' }
  let(:contributing_library) { ContributingLibrary.create(label: 'Example Library', uri: 'http://www.example.org') }
  let(:iiif_manifest_1) { IIIF::Manifest.create(uri: 'http://example.org/1.json', label: 'Version 1') }
  let(:version_1) do
    Version.create(
      contributing_library: contributing_library,
      label: 'version 1',
      based_on_original: true,
      owner_system_number: '1234',
      rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
      iiif_manifest: iiif_manifest_1
    )
  end
  let(:iiif_manifest_2) { IIIF::Manifest.create(uri: 'http://example.org/2.json', label: 'Version 2') }
  let(:version_2) do
    Version.create(
      contributing_library: contributing_library,
      label: 'version 2',
      based_on_original: true,
      owner_system_number: '1234',
      rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
      iiif_manifest: iiif_manifest_2
    )
  end
  let(:volume_2) { Volume.create(digital_cico_number: digital_cico_number, versions: [version_2]) }
  let(:volume_1) { Volume.create(digital_cico_number: digital_cico_number, versions: [version_1]) }
  let(:marc_path) { File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cicognara.marc.xml') }
  let(:marcxml) { File.open(marc_path) { |f| Nokogiri::XML(f) } }
  let(:marc_record_2) { MarcRecord.create(source: marcxml, file_uri: file_uri_2) }
  let(:file_uri_2) { 'file:///test.mrx//marc:record[1]' }
  let(:book_2) { Book.create(volumes: [volume_2], marc_record: marc_record_2) }
  let(:file_uri_1) { 'file:///test.mrx//marc:record[0]' }
  let(:marc_record_1) { MarcRecord.create(source: marcxml, file_uri: file_uri_1) }
  let(:book_1) { Book.create(volumes: [volume_1], marc_record: marc_record_1) }
  let(:entry) { Entry.create(n_value: '15', books: [book_1, book_2]) }
  let(:tei_path) { File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cicognara.marc.xml') }

  before do
    solr = RSolr.connect(url: Blacklight.connection_config[:url])
    solr.delete_by_query('*:*')
    solr.add(Cicognara::TEIIndexer.new(tei_path, marc_path).solr_docs)
    solr.commit
  end

  describe '#as_json' do
    subject(:json) { JSON.parse(entry_collection.to_json) }

    before do
      version_1
      version_2
    end

    context 'when given an entry with two books each with a manifest' do
      it 'generates a collection with two sub-collections each with a manifest' do
        collections = json['collections']

        expect(json['label']).to eq entry.item_label
        expect(json['collections'].length).to eq 2
        expect(json['collections'][0]['manifests'].length).to eq 1
        expect(json['collections'][0]['manifests'].first).to include '@id' => 'http://example.org/1.json'
        expect(json['collections'][0]['label']).to eq('Commentario inedito di Lorenzo Ghiberti estratto da manoscritti della Biblioteca Magliabecchiana')
        expect(json['collections'][1]['manifests'].first).to include '@id' => 'http://example.org/2.json'
      end
    end
  end
end
