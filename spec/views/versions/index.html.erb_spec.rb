require 'rails_helper'

RSpec.describe 'versions/index', type: :view do
  let(:book) { Book.create! }
  let(:contrib) { ContributingLibrary.create! label: 'Lib 1', uri: 'http://example.org/lib' }
  let(:version1) { Version.create!(book_id: book, label: 'v1', manifest: 'http://example.org/1', contributing_library_id: contrib.id) }
  let(:version2) { Version.create!(book_id: book, label: 'v2', manifest: 'http://example.org/2', contributing_library_id: contrib.id) }

  before do
    assign(:book, book)
    assign(:versions, [version1, version2])
  end

  after do
    book.destroy
    contrib.destroy
    version1.destroy
    version2.destroy
  end

  it 'renders a list of versions' do
    render
  end
end
