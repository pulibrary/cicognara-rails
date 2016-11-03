require 'rails_helper'

RSpec.describe IIIF::EntryCollection do
  subject { described_class.new(entry) }
  before(:all) do
    marc = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cicognara.marc.xml')
    tei = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cicognara.tei.xml')
    solr = RSolr.connect(url: Blacklight.connection_config[:url])
    solr.delete_by_query('*:*')
    solr.add(Cicognara::TEIIndexer.new(tei, marc).solr_docs)
    solr.commit
  end

  after(:all) do
    Book.destroy_all
    Entry.destroy_all
    Version.destroy_all
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

  after(:all) { Book.destroy_all }
  describe '#as_json' do
    before do
      version_1
      version_2
    end
    let(:json) { JSON.parse(subject.to_json) }
    let(:entry) { Entry.where(n_value: '15').first }
    context 'when given an entry with two books each with a manifest' do
      it 'generates a collection with two sub-collections each with a manifest' do
        expect(json['label']).to eq entry.item_label
        expect(json['collections'].length).to eq 2
        expect(json['collections'][0]['manifests'].length).to eq 1
        expect(json['collections'][0]['label']).to eq 'Libellus de vtilitate et harmonia artium tum futuro iurisconsulto, tum liberalium disciplinarum politiorisue literaturae studiosis utilissimus authore Nicolao Bro[n?]tio duacensi'
        expect(json['collections'][1]['manifests'].length).to eq 1
      end
    end
  end
end
