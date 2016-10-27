require 'rails_helper'

RSpec.describe 'versions/edit', type: :view do
  let(:book) { Book.create! }
  let(:contrib) { ContributingLibrary.create! label: 'Lib 1', uri: 'http://example.org/lib' }
  let(:version) { Version.create!(label: 'v1', manifest: 'http://example.org/1', contributing_library: contrib, based_on_original: false, owner_system_number: '1234', rights: 'http://creativecommons.org/publicdomain/mark/1.0/') }

  before do
    assign(:book, book)
    assign(:version, version)
  end

  after do
    book.destroy
    contrib.destroy
    version.destroy
  end

  it 'renders the edit version form' do
    render

    assert_select 'form[action=?][method=?]', book_version_path(book, version), 'post' do
    end
  end
end
