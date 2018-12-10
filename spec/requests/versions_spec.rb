require 'rails_helper'

RSpec.describe 'Versions', type: :request do
  let(:marc_documents) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }
  let(:tei_documents) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml') }
  let(:solr_client) { Blacklight.default_index.connection }
  let(:tei_indexer) { Cicognara::TEIIndexer.new(tei_documents, marc_documents, solr_client) }
  let(:solr_documents) { tei_indexer.solr_docs }
  let(:book) { Book.first }
  let(:contrib) { ContributingLibrary.create!(label: 'Library 1', uri: 'http://example.org/lib') }
  let(:version) do
    Version.create!(book_id: book.id, label: 'Version 1', manifest: 'http://example.org/1.json',
                    contributing_library_id: contrib.id, owner_system_number: '1234',
                    rights: 'http://creativecommons.org/publicdomain/mark/1.0/', based_on_original: false)
  end

  before do
    stub_manifest('http://example.org/1.json')
    solr_client.add(solr_documents)
    solr_client.commit
    stub_admin_user
  end

  describe 'GET versions' do
    it 'shows a list of versions' do
      get book_version_path(book, version)
      expect(response).to have_http_status(200)
    end
  end
end
