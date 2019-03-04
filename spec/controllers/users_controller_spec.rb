require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:valid_attributes) { { email: 'alice@example.org', role: 'admin' } }
  let(:invalid_attributes) { { email: nil } }

  before do
    stub_admin_user
  end

  describe 'GET #index' do
    it 'assigns all users as @users' do
      get :index
      expect(assigns(:users)).to eq([User.first])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested user as @user' do
      user = User.create! valid_attributes
      get :show, params: { id: user }
      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested user as @user' do
      user = User.create! valid_attributes
      get :edit, params: { id: user }
      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { email: 'bob@example.org', role: 'curator' } }

      it 'updates the requested user' do
        user = User.create! valid_attributes
        put :update, params: { id: user.to_param, user: new_attributes }
        user.reload
        expect(user.email).to eq('bob@example.org')
        expect(user.role).to eq('curator')
      end

      it 'assigns the requested user as @user' do
        user = User.create! valid_attributes
        put :update, params: { id: user, user: valid_attributes }
        expect(assigns(:user)).to eq(user)
      end

      it 'redirects to the user' do
        user = User.create! valid_attributes
        put :update, params: { id: user, user: valid_attributes }
        expect(response).to redirect_to(user_path(user))
      end
    end

    context 'with invalid params' do
      it 'assigns the user as @user' do
        user = User.create! valid_attributes
        put :update, params: { id: user.to_param, user: invalid_attributes }
        expect(assigns(:user)).to eq(user)
      end

      it "re-renders the 'edit' template" do
        user = User.create! valid_attributes
        put :update, params: { id: user.to_param, user: invalid_attributes }
        expect(response).to redirect_to(user_path(user))
        expect(response).not_to be_successful
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested user' do
      user = User.create! valid_attributes
      expect do
        delete :destroy, params: { id: user }
      end.to change(User, :count).by(-1)
    end

    it 'redirects to the users list' do
      user = User.create! valid_attributes
      delete :destroy, params: { id: user }
      expect(response).to redirect_to(users_url)
    end
  end
end
