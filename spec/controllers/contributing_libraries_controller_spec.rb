require 'rails_helper'

RSpec.describe ContributingLibrariesController, type: :controller do
  let(:valid_attributes) { { label: 'My Library', uri: 'http://example.org/1' } }
  let(:invalid_attributes) { { label: nil } }
  let(:valid_session) { {} }

  describe 'GET #index' do
    it 'assigns all contributing_libraries as @contributing_libraries' do
      contributing_library = ContributingLibrary.create! valid_attributes
      get :index, valid_session
      expect(assigns(:contributing_libraries)).to eq([contributing_library])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested contributing_library as @contributing_library' do
      contributing_library = ContributingLibrary.create! valid_attributes
      get :show, { id: contributing_library }, valid_session
      expect(assigns(:contributing_library)).to eq(contributing_library)
    end
  end

  describe 'GET #new' do
    it 'assigns a new contributing_library as @contributing_library' do
      get :new, valid_session
      expect(assigns(:contributing_library)).to be_a_new(ContributingLibrary)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested contributing_library as @contributing_library' do
      contributing_library = ContributingLibrary.create! valid_attributes
      get :edit, { id: contributing_library }, valid_session
      expect(assigns(:contributing_library)).to eq(contributing_library)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new ContributingLibrary' do
        expect do
          post :create, { contributing_library: valid_attributes }, valid_session
        end.to change(ContributingLibrary, :count).by(1)
      end

      it 'assigns a newly created contributing_library as @contributing_library' do
        post :create, { contributing_library: valid_attributes }, valid_session
        expect(assigns(:contributing_library)).to be_a(ContributingLibrary)
        expect(assigns(:contributing_library)).to be_persisted
      end

      it 'redirects to the created contributing_library' do
        post :create, { contributing_library: valid_attributes }, valid_session
        expect(response).to redirect_to(contributing_library_url(ContributingLibrary.last))
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved contributing_library as @contributing_library' do
        post :create, { contributing_library: invalid_attributes }, valid_session
        expect(assigns(:contributing_library)).to be_a(ContributingLibrary)
      end

      it "re-renders the 'new' template" do
        post :create, { contributing_library: invalid_attributes }, valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { label: 'ContributingLibrary 2', uri: 'http://example.org/2' } }

      it 'updates the requested contributing_library' do
        contributing_library = ContributingLibrary.create! valid_attributes
        put :update, { id: contributing_library.to_param, contributing_library: new_attributes }, valid_session
        contributing_library.reload
        expect(contributing_library.label).to eq('ContributingLibrary 2')
        expect(contributing_library.uri).to eq('http://example.org/2')
      end

      it 'assigns the requested contributing_library as @contributing_library' do
        contributing_library = ContributingLibrary.create! valid_attributes
        put :update, { id: contributing_library, contributing_library: valid_attributes }, valid_session
        expect(assigns(:contributing_library)).to eq(contributing_library)
      end

      it 'redirects to the contributing_library' do
        contributing_library = ContributingLibrary.create! valid_attributes
        put :update, { id: contributing_library, contributing_library: valid_attributes }, valid_session
        expect(response).to redirect_to(contributing_library_path(contributing_library))
      end
    end

    context 'with invalid params' do
      it 'assigns the contributing_library as @contributing_library' do
        contributing_library = ContributingLibrary.create! valid_attributes
        put :update, { id: contributing_library.to_param, contributing_library: invalid_attributes }, valid_session
        expect(assigns(:contributing_library)).to eq(contributing_library)
      end

      it "re-renders the 'edit' template" do
        contributing_library = ContributingLibrary.create! valid_attributes
        put :update, { id: contributing_library.to_param, contributing_library: invalid_attributes }, valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested contributing_library' do
      contributing_library = ContributingLibrary.create! valid_attributes
      expect do
        delete :destroy, { id: contributing_library }, valid_session
      end.to change(ContributingLibrary, :count).by(-1)
    end

    it 'redirects to the contributing_libraries list' do
      contributing_library = ContributingLibrary.create! valid_attributes
      delete :destroy, { id: contributing_library }, valid_session
      expect(response).to redirect_to(contributing_libraries_url)
    end
  end
end
