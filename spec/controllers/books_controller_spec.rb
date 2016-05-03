require 'rails_helper'

RSpec.describe BooksController, type: :controller do
  let(:book) { Book.create digital_cico_number: 'cico:abc' }
  let(:valid_session) { {} }

  after do
    book.destroy
  end

  describe 'GET #index' do
    it 'assigns all books as @books' do
      get :index, valid_session
      expect(assigns(:books)).to eq([book])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested book as @book' do
      get :show, { id: book }, valid_session
      expect(assigns(:book)).to eq(book)
    end
  end
end
