require 'rails_helper'

RSpec.describe CatalogController, type: :controller do
  let(:marc) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }
  let(:tei) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml') }
  let(:solr) { Blacklight.default_index.connection }
  let(:index) { Cicognara::TEIIndexer.new(tei, marc, solr) }
  let(:solr_docs) { index.solr_docs }

  before do
    stub_manifest('http://example.org/1.json')
    solr.delete_by_query('*:*')
    solr.add(solr_docs)
    solr.commit
  end

  describe 'GET #show' do
    it 'retrieves linked documents' do
      get :show, params: { id: '2' }

      linked_documents = assigns(:linked_documents)
      expect(linked_documents.length).to eq 1
      file_uri_digest = Digest::MD5.hexdigest(linked_documents.first['file_uri_s'].first)
      expect(linked_documents.first['id']).to include file_uri_digest
    end

    it 'does not error when there are no linked documents' do
      get :show, params: { id: '1' }
      expect(assigns(:linked_documents)).to eq []
    end

    it 'book has configured display fields from marc' do
      get :show, params: { id: '2' }

      linked_documents = assigns(:linked_documents)
      expect(linked_documents.first['title_addl_display']).to include('De incertitudine et vanitate scientiarum declamatio inuestiua')
    end
  end

  describe 'GET #index' do
    render_views
    let(:response_body) { Capybara::Node::Simple.new(response.body) }
    it "doesn't show the welcome page" do
      get :index

      expect(response_body).to have_selector '.document'
    end
  end
end
