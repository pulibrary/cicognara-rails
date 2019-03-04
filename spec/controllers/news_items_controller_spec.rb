require 'rails_helper'

RSpec.describe NewsItemsController, type: :controller do
  let(:valid_attributes) { { title: 'Title', body: 'Body' } }
  let(:invalid_attributes) { { title: '', body: 'Body' } }
  let(:user) { stub_admin_user }

  before do
    user
  end

  describe 'GET #index' do
    it 'assigns all news_items as @news_items, in reverse creation order' do
      first_news_item = NewsItem.create! valid_attributes.merge(user_id: user.id)
      second_news_item = NewsItem.create! valid_attributes.merge(user_id: user.id)
      get :index, params: {}
      expect(assigns(:news_items)).to eq([second_news_item, first_news_item])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested news_item as @news_item' do
      news_item = NewsItem.create! valid_attributes.merge(user_id: user.id)
      get :show, params: { id: news_item.to_param }
      expect(assigns(:news_item)).to eq(news_item)
    end
  end

  describe 'GET #new' do
    it 'assigns a new news_item as @news_item' do
      get :new, params: {}
      expect(assigns(:news_item)).to be_a_new(NewsItem)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested news_item as @news_item' do
      news_item = NewsItem.create! valid_attributes.merge(user_id: user.id)
      get :edit, params: { id: news_item.to_param }
      expect(assigns(:news_item)).to eq(news_item)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new NewsItem' do
        expect do
          post :create, params: { news_item: valid_attributes }
        end.to change(NewsItem, :count).by(1)
      end

      it 'assigns a newly created news_item as @news_item' do
        post :create, params: { news_item: valid_attributes }
        expect(assigns(:news_item)).to be_a(NewsItem)
        expect(assigns(:news_item)).to be_persisted
      end

      it 'redirects to the news items index' do
        post :create, params: { news_item: valid_attributes }
        expect(response).to redirect_to(news_items_url)
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved news_item as @news_item' do
        post :create, params: { news_item: invalid_attributes }
        expect(assigns(:news_item)).to be_a_new(NewsItem)
      end

      it "re-renders the 'new' template" do
        post :create, params: { news_item: invalid_attributes }
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { title: 'New title', body: 'New body' } }

      it 'updates the requested news_item' do
        news_item = NewsItem.create! valid_attributes.merge(user_id: user.id)
        put :update, params: { id: news_item.to_param, news_item: new_attributes }
        news_item.reload
        expect(news_item.title).to eq('New title')
        expect(news_item.body).to eq('New body')
      end

      it 'assigns the requested news_item as @news_item' do
        news_item = NewsItem.create! valid_attributes.merge(user_id: user.id)
        put :update, params: { id: news_item.to_param, news_item: valid_attributes }
        expect(assigns(:news_item)).to eq(news_item)
      end

      it 'redirects to the news items index' do
        news_item = NewsItem.create! valid_attributes.merge(user_id: user.id)
        put :update, params: { id: news_item.to_param, news_item: valid_attributes }
        expect(response).to redirect_to(news_items_url)
      end
    end

    context 'with invalid params' do
      it 'assigns the news_item as @news_item' do
        news_item = NewsItem.create! valid_attributes.merge(user_id: user.id)
        put :update, params: { id: news_item.to_param, news_item: invalid_attributes }
        expect(assigns(:news_item)).to eq(news_item)
      end

      it "re-renders the 'edit' template" do
        news_item = NewsItem.create! valid_attributes.merge(user_id: user.id)
        put :update, params: { id: news_item.to_param, news_item: invalid_attributes }
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested news_item' do
      news_item = NewsItem.create! valid_attributes.merge(user_id: user.id)
      expect do
        delete :destroy, params: { id: news_item.to_param }
      end.to change(NewsItem, :count).by(-1)
    end

    it 'redirects to the news_items list' do
      news_item = NewsItem.create! valid_attributes.merge(user_id: user.id)
      delete :destroy, params: { id: news_item.to_param }
      expect(response).to redirect_to(news_items_url)
    end
  end
end
