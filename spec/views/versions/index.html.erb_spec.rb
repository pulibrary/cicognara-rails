require 'rails_helper'

RSpec.describe 'versions/index', type: :view do
  let(:book) { Book.create! digital_cico_number: 'cico:xyz' }
  let(:contrib) { ContributingLibrary.create! label: 'Lib 1', uri: 'http://example.org/lib' }
  let(:version1) { Version.create!(book: book, label: 'v1', manifest: 'http://example.org/1', contributing_library: contrib, based_on_original: false, owner_system_number: '1234', rights: 'http://creativecommons.org/publicdomain/mark/1.0/') }
  let(:version2) { Version.create!(book: book, label: 'v2', manifest: 'http://example.org/2', contributing_library: contrib, based_on_original: false, owner_system_number: '1234', rights: 'http://creativecommons.org/publicdomain/mark/1.0/') }

  before do
    Book.destroy_all
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
