require 'rails_helper'

RSpec.describe 'Versions', type: :request do
  let(:book) { Book.create }
  before { stub_admin_user }

  after do
    book.destroy
  end

  describe 'GET /versions' do
    it 'shows a list of versions' do
      get book_versions_path(book)
      expect(response).to have_http_status(200)
    end
  end
end
