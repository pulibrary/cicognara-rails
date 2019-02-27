require 'rails_helper'

RSpec.describe 'versions/show', type: :view do
  let(:book) { Book.create!(digital_cico_number: '1') }
  let(:contrib) { ContributingLibrary.create! label: 'Lib 1', uri: 'http://example.org/lib' }
  let(:version) { Version.create!(book: book, label: 'v1', manifest: 'http://example.org/1.json', contributing_library: contrib, based_on_original: false, owner_system_number: '1234', rights: 'http://creativecommons.org/publicdomain/mark/1.0/') }

  before do
    stub_manifest('http://example.org/1.json')
    assign(:book, book)
    assign(:version, version)
  end

  it 'renders attributes in <p>' do
    render
  end
end
