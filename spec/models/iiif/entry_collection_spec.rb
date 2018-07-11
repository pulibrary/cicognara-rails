require 'rails_helper'

RSpec.describe IIIF::EntryCollection do
  subject { described_class.new(entry) }
  before do
    marc = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cicognara.marc.xml')
    tei = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cicognara.tei.xml')
    solr = RSolr.connect(url: Blacklight.connection_config[:url])
    solr.delete_by_query('*:*')
    solr.add(Cicognara::TEIIndexer.new(tei, marc).solr_docs)
    solr.commit
  end

  let(:contributing_library) { ContributingLibrary.create! label: 'Example Library', uri: 'http://www.example.org' }
  let(:version_1) do
    Version.create! contributing_library: contributing_library, book: entry.books.first,
                    label: 'version 1', based_on_original: true, owner_system_number: '1234',
                    rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
                    manifest: 'http://example.org/1.json'
  end
  let(:version_2) do
    Version.create! contributing_library: contributing_library, book: entry.books.second,
                    label: 'version 2', based_on_original: true, owner_system_number: '1234',
                    rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
                    manifest: 'http://example.org/2.json'
  end
  let(:version_3) do
    Version.create! contributing_library: contributing_library, book: entry.books.second,
                    label: 'version 3', based_on_original: false, owner_system_number: '1234',
                    rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
                    manifest: 'http://example.org/3.json'
  end

  describe '#as_json' do
    before do
      version_1
      version_2
      version_3
    end
    let(:json) { JSON.parse(subject.to_json) }
    let(:entry) { Entry.where(n_value: '15').first }
    context 'when given an entry with two books each with a manifest' do
      it 'generates a collection with two sub-collections each with a manifest' do
        expect(json['label']).to eq entry.item_label
        expect(json['collections'].length).to eq 2
        collection_labels = [json['collections'][0]['label'], json['collections'][1]['label']]
        expect(collection_labels).to contain_exactly('Libellus compendiariam tum virtutis adipiscendae tum literarum parandarum rationem perdoce[n?]s, bene beateq[ue] uiuere cupienti, aprimis utilis authore Nicolao Bro[n?]tio Duacensi ; adiecta sunt ab eode[m] carmina, facile[?] studendi Iuri modu[m?] tradentia', 'Libellus de vtilitate et harmonia artium tum futuro iurisconsulto, tum liberalium disciplinarum politiorisue literaturae studiosis utilissimus authore Nicolao Bro[n?]tio duacensi')
        version_labels = json['collections'].map { |c| c['manifests'] }.map { |arr| arr.map { |m| m['label'] } }
        expect(version_labels).to contain_exactly(['version 1'], ['version 3', 'version 2'])
      end
    end
  end
end
