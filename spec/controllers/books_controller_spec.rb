require 'rails_helper'

RSpec.describe BooksController, type: :controller do
  let(:book) { Book.create digital_cico_number: 'cico:abc' }

  before do
    stub_admin_user
    Book.delete_all
  end

  after do
    book.destroy
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
end
