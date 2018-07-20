require 'rails_helper'

RSpec.describe VersionsController, type: :controller do
  let(:entry) { Entry.create(n_value: '15') }
  let(:marc_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }
  let(:marcxml) { File.open(marc_path) { |f| Nokogiri::XML(f) } }
  let(:file_uri) { 'file:///test.mrx//marc:record[0]' }
  let(:marc_record) { MarcRecord.create(source: marcxml, file_uri: file_uri) }
  let(:volume) { Volume.create(digital_cico_number: 'cico:abc') }
  let(:book) { Book.create(entry: entry, marc_record: marc_record, volumes: [volume]) }
  let(:iiif_manifest) { IIIF::Manifest.create(uri: 'http://example.org/1.json', label: 'Version 1') }
  let(:contrib) { ContributingLibrary.create(label: 'Library 1', uri: 'http://example.org/lib') }
  let(:valid_attributes) do
    {
      volume_id: volume.id,
      label: 'Version 1',
      iiif_manifest_id: iiif_manifest.id,
      contributing_library_id: contrib.id,
      rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
      owner_system_number: '1234',
      based_on_original: false
    }
  end
  let(:invalid_attributes) { { label: nil } }

  before do
    stub_admin_user
  end

  describe 'GET #show' do
    let(:version) { Version.create(valid_attributes) }

    it 'assigns the requested version as @version' do
      get :show, params: { book_id: book, volume_id: volume, id: version }
      expect(assigns(:version)).to eq(version)
    end
  end

  describe 'GET #new' do
    it 'assigns a new version as @version' do
      get :new, params: { book_id: book, volume_id: volume }
      expect(assigns(:version)).to be_a_new(Version)
    end
  end

  describe 'GET #edit' do
    let(:version) { Version.create(valid_attributes) }
    it 'assigns the requested version as @version' do
      #version = Version.create! valid_attributes
      get :edit, params: { book_id: book, volume_id: volume, id: version }
      expect(assigns(:version)).to eq(version)
    end
  end

  describe 'POST #create' do
    let(:solr) { Blacklight.default_index.connection }
    context 'with valid params' do
      it 'creates a new Version' do
        expect do
          post :create, params: { book_id: book, volume_id: volume, version: valid_attributes }
        end.to change(Version, :count).by(1)
      end

      it 'assigns a newly created version as @version' do
        post :create, params: { book_id: book, volume_id: volume, version: valid_attributes }
        expect(assigns(:version)).to be_a(Version)
        expect(assigns(:version)).to be_persisted
      end

      it 'redirects to the created version' do
        post :create, params: { book_id: book, volume_id: volume, version: valid_attributes }
        expect(response).to redirect_to(book_volume_version_url(volume.book, volume, Version.last))
      end

      context "when the Version is indexed into Solr" do
        let(:doc) do
          solr.get(
            'select',
            params: {
              qt: 'document',
              q: "id:#{RSolr.solr_escape(marc_record.file_uri)} OR id:#{RSolr.solr_escape(entry.n_value)}",
              :"facet.field" => 'contributing_library_facet',
              :facet => 'on'
            }
          )
        end

        before do
          post :create, params: { book_id: book, volume_id: volume, version: valid_attributes }
        end

        it 'indexes attributes for the related Book and Entry' do
          expect(doc).to include 'facet_counts'
          expect(doc['facet_counts']).to include 'facet_fields'
          expect(doc['facet_counts']['facet_fields']).to include 'contributing_library_facet'
          expect(doc['facet_counts']['facet_fields']['contributing_library_facet']).to eq(["Library 1", 2])
        end
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved version as @version' do
        post :create, params: { book_id: book, volume_id: volume, version: invalid_attributes }
        expect(assigns(:version)).to be_a(Version)
      end

      it "re-renders the 'new' template" do
        post :create, params: { book_id: book, volume_id: volume, version: invalid_attributes }
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { label: 'Version 2', manifest: 'http://example.org/2' } }

      it 'updates the requested version' do
        version = Version.create! valid_attributes
        put :update, params: { book_id: book, volume_id: volume, id: version.to_param, version: new_attributes }
        version.reload
        expect(version.label).to eq('Version 2')
        expect(version.iiif_manifest).to eq(iiif_manifest)
      end

      it 'assigns the requested version as @version' do
        version = Version.create! valid_attributes
        put :update, params: { book_id: book, volume_id: volume, id: version, version: valid_attributes }
        expect(assigns(:version)).to eq(version)
      end

      it 'redirects to the version' do
        version = Version.create! valid_attributes
        put :update, params: { book_id: book, volume_id: volume, id: version, version: valid_attributes }
        expect(response).to redirect_to(book_volume_version_path(book, volume, version))
      end
    end

    context 'with invalid params' do
      it 'assigns the version as @version' do
        version = Version.create! valid_attributes
        put :update, params: { book_id: book, volume_id: volume, id: version.to_param, version: invalid_attributes }
        expect(assigns(:version)).to eq(version)
      end

      it "re-renders the 'edit' template" do
        version = Version.create! valid_attributes
        put :update, params: { book_id: book, volume_id: volume, id: version.to_param, version: invalid_attributes }
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested version' do
      version = Version.create! valid_attributes
      expect do
        delete :destroy, params: { book_id: book, volume_id: volume, id: version }
      end.to change(Version, :count).by(-1)
    end

    it 'redirects to the versions list' do
      version = Version.create! valid_attributes
      delete :destroy, params: { book_id: book, volume_id: volume, id: version }
      expect(response).to redirect_to(book_url(book))
    end
  end
end
