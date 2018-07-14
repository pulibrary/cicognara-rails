require 'rails_helper'

RSpec.describe IIIF::EntryCollection do
  subject(:entry_collection) { described_class.new(entry) }

  let(:marcxml) { File.open(marc_path) { |f| Nokogiri::XML(f) } }
  let(:file_uri) { "file:///test.mrx//marc:record[0]" }
  let(:marc_record) { MarcRecord.create(source: marcxml, file_uri: file_uri) }
  let(:book) { Book.create(marc_record: marc_record) }
  let(:entry) { Entry.create(n_value: '15', books: [book]) }
  let(:marc_path) { File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cicognara.marc.xml') }
  let(:tei_path) { File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cicognara.marc.xml') }

  before do
    solr = RSolr.connect(url: Blacklight.connection_config[:url])
    solr.delete_by_query('*:*')
    solr.add(Cicognara::TEIIndexer.new(tei_path, marc_path).solr_docs)
    solr.commit
  end

  let(:contributing_library) { ContributingLibrary.create(label: 'Example Library', uri: 'http://www.example.org') }
  let(:version_1) do
    Version.create(
      contributing_library: contributing_library,
      book: entry.books.first,
      label: 'version 1',
      based_on_original: true,
      owner_system_number: '1234',
      rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
      manifest: 'http://example.org/1.json'
    )
  end

  let(:version_2) do
    Version.create(
      contributing_library: contributing_library,
      book: entry.books.second,
      label: 'version 2',
      based_on_original: true,
      owner_system_number: '1234',
      rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
      manifest: 'http://example.org/2.json'
    )
  end

  describe '#as_json' do
    subject(:json) { JSON.parse(entry_collection.to_json) }

    before do
      version_1
      version_2
    end

    context 'when given an entry with two books each with a manifest' do
      it 'generates a collection with two sub-collections each with a manifest' do
        #binding.pry
        expect(json['label']).to eq entry.item_label
        expect(json['collections'].length).to eq 2
        expect(json['collections'][0]['manifests'].length).to eq 1
        labels = [json['collections'][0]['label'], json['collections'][1]['label']]
        expect(labels).to contain_exactly('Libellus compendiariam tum virtutis adipiscendae tum literarum parandarum rationem perdoce[n?]s, bene beateq[ue] uiuere cupienti, aprimis utilis authore Nicolao Bro[n?]tio Duacensi ; adiecta sunt ab eode[m] carmina, facile[?] studendi Iuri modu[m?] tradentia', 'Libellus de vtilitate et harmonia artium tum futuro iurisconsulto, tum liberalium disciplinarum politiorisue literaturae studiosis utilissimus authore Nicolao Bro[n?]tio duacensi')
        expect(json['collections'][1]['manifests'].length).to eq 1
      end
    end
  end
end
