require 'rails_helper'

RSpec.describe BooksController, type: :controller do
  let(:marc_documents) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }
  let(:tei_documents) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml') }
  let(:solr_client) { Blacklight.default_index.connection }
  let(:tei_indexer) { Cicognara::TEIIndexer.new(tei_documents, marc_documents, solr_client) }
  let(:solr_documents) { tei_indexer.solr_docs }
  let(:book) { Book.first }

  before do
    solr_client.add(solr_documents)
    solr_client.commit
    stub_admin_user
  end

  describe 'GET #index' do
    it 'assigns all books as @books' do
      get :index
      expect(assigns(:books)).to include(book)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested book as @book' do
      get :show, params: { id: book }
      expect(assigns(:book)).to eq(book)
    end
  end
end
