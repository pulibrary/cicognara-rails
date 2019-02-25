require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:entry) { Entry.create!(n_value: '1') }
  let(:entry_url) { solr_document_path(entry) }
  let(:valid_attributes) { { entry_id: entry.id, text: 'this is a comment' } }
  let(:invalid_attributes) { { entry_id: entry.id, text: '' } }
  let(:user) { stub_admin_user }
  let(:comment) { Comment.create!(valid_attributes.merge(user_id: user.id)) }

  before do
    user
  end

  describe 'GET #edit' do
    it 'assigns the requested comment as @comment' do
      get :edit, params: { id: comment.to_param }
      expect(assigns(:comment)).to eq(comment)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Comment' do
        expect do
          post :create, params: { comment: valid_attributes }
        end.to change(Comment, :count).by(1)
      end

      it 'assigns a newly created comment as @comment' do
        post :create, params: { comment: valid_attributes }
        expect(assigns(:comment)).to be_a(Comment)
        expect(assigns(:comment)).to be_persisted
      end

      it 'redirects to the entry where the comment was posted' do
        post :create, params: { comment: valid_attributes }
        expect(response).to redirect_to(entry_url)
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved comment as @comment' do
        post :create, params: { comment: invalid_attributes }
        expect(assigns(:comment)).to be_a_new(Comment)
      end

      it "re-renders the 'new' template" do
        post :create, params: { comment: invalid_attributes }
        expect(response).to redirect_to(entry_url)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { entry_id: entry.id, text: 'this is an updated comment' } }

      it 'updates the requested comment' do
        put :update, params: { id: comment.to_param, comment: new_attributes }
        comment.reload
        expect(comment.text).to eq('this is an updated comment')
      end

      it 'assigns the requested comment as @comment' do
        put :update, params: { id: comment.to_param, comment: valid_attributes }
        expect(assigns(:comment)).to eq(comment)
      end

      it 'redirects to the entry the comment is attached to' do
        put :update, params: { id: comment.to_param, comment: valid_attributes }
        expect(response).to redirect_to(entry_url)
      end
    end

    context 'with invalid params' do
      it 'assigns the comment as @comment' do
        put :update, params: { id: comment.to_param, comment: invalid_attributes }
        expect(assigns(:comment)).to eq(comment)
      end

      it "re-renders the 'edit' template" do
        put :update, params: { id: comment.to_param, comment: invalid_attributes }
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested comment' do
      comment
      expect do
        delete :destroy, params: { id: comment.to_param }
      end.to change(Comment, :count).by(-1)
    end

    it 'redirects to the entry the comment was attached to' do
      comment
      delete :destroy, params: { id: comment.to_param }
      expect(response).to redirect_to(entry_url)
    end
  end
end
