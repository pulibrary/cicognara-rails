require 'rails_helper'

RSpec.describe BooksController, type: :controller do
  let(:book) { Book.create digital_cico_number: 'cico:abc' }

  before do
    stub_admin_user
  end

  describe 'GET #index' do
    it 'assigns all books as @books' do
      get :index
      expect(assigns(:books)).to eq([book])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested book as @book' do
      get :show, params: { id: book }
      expect(assigns(:book)).to eq(book)
    end
  end

  describe 'GET #manifest' do
    it 'builds a manifest based on id' do
      get :manifest, params: { id: book.id, format: :json }

      expect(response).to be_success
    end
  end
end
