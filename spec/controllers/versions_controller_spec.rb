require 'rails_helper'

RSpec.describe VersionsController, type: :controller do
  let(:entry) { Entry.create }
  let(:book) { Book.create digital_cico_number: 'cico:abc', entries: [entry] }
  let(:contrib) { ContributingLibrary.create label: 'Library 1', uri: 'http://example.org/lib' }
  let(:valid_attributes) do
    {
      book_id: book.id,
      label: 'Version 1',
      manifest: 'http://example.org/1',
      contributing_library_id: contrib.id,
      rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
      owner_system_number: '1234',
      based_on_original: false
    }
  end
  let(:invalid_attributes) { { label: nil } }

  before do
    stub_admin_user
    Book.destroy_all
  end

  after do
    book.destroy
    contrib.destroy
  end

  describe 'GET #index' do
    it 'assigns all versions as @versions' do
      version = Version.create! valid_attributes
      get :index, params: { book_id: book }
      expect(assigns(:versions)).to eq([version])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested version as @version' do
      version = Version.create! valid_attributes
      get :show, params: { book_id: book, id: version }
      expect(assigns(:version)).to eq(version)
    end
  end

  describe 'GET #new' do
    it 'assigns a new version as @version' do
      get :new, params: { book_id: book }
      expect(assigns(:version)).to be_a_new(Version)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested version as @version' do
      version = Version.create! valid_attributes
      get :edit, params: { book_id: book, id: version }
      expect(assigns(:version)).to eq(version)
    end
  end

  describe 'POST #create' do
    let(:solr) { Blacklight.default_index.connection }
    context 'with valid params' do
      it 'creates a new Version' do
        expect do
          post :create, params: { book_id: book.id, version: valid_attributes }
        end.to change(Version, :count).by(1)
      end

      it 'assigns a newly created version as @version' do
        post :create, params: { book_id: book.id, version: valid_attributes }
        expect(assigns(:version)).to be_a(Version)
        expect(assigns(:version)).to be_persisted
      end

      it 'redirects to the created version' do
        post :create, params: { book_id: book.id, version: valid_attributes }
        expect(response).to redirect_to(book_version_url(book, Version.last))
      end

      it 'updates the solr index for its book and its entries' do
        post :create, params: { book_id: book, version: valid_attributes }

        doc = solr.get('select', params: { qt: 'document', q: "id:#{RSolr.solr_escape(book.digital_cico_number)} OR id:#{RSolr.solr_escape(entry.n_value)}", :"facet.field" => 'contributing_library_facet', :facet => 'on' })
        facets = Hash[doc['facet_counts']['facet_fields']['contributing_library_facet'].each_slice(2).to_a]

        expect(facets['Library 1']).to eq 2
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved version as @version' do
        post :create, params: { book_id: book, version: invalid_attributes }
        expect(assigns(:version)).to be_a(Version)
      end

      it "re-renders the 'new' template" do
        post :create, params: { book_id: book, version: invalid_attributes }
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { label: 'Version 2', manifest: 'http://example.org/2' } }

      it 'updates the requested version' do
        version = Version.create! valid_attributes
        put :update, params: { book_id: book, id: version.to_param, version: new_attributes }
        version.reload
        expect(version.label).to eq('Version 2')
        expect(version.manifest).to eq('http://example.org/2')
      end

      it 'assigns the requested version as @version' do
        version = Version.create! valid_attributes
        put :update, params: { book_id: book, id: version, version: valid_attributes }
        expect(assigns(:version)).to eq(version)
      end

      it 'redirects to the version' do
        version = Version.create! valid_attributes
        put :update, params: { book_id: book, id: version, version: valid_attributes }
        expect(response).to redirect_to(book_version_path(book, version))
      end
    end

    context 'with invalid params' do
      it 'assigns the version as @version' do
        version = Version.create! valid_attributes
        put :update, params: { book_id: book, id: version.to_param, version: invalid_attributes }
        expect(assigns(:version)).to eq(version)
      end

      it "re-renders the 'edit' template" do
        version = Version.create! valid_attributes
        put :update, params: { book_id: book, id: version.to_param, version: invalid_attributes }
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested version' do
      version = Version.create! valid_attributes
      expect do
        delete :destroy, params: { book_id: book, id: version }
      end.to change(Version, :count).by(-1)
    end

    it 'redirects to the versions list' do
      version = Version.create! valid_attributes
      delete :destroy, params: { book_id: book, id: version }
      expect(response).to redirect_to(book_versions_url(book))
    end
  end
end
