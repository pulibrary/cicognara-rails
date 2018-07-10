require 'rails_helper'

RSpec.describe 'versions/new', type: :view do
  let(:book) { Book.create! }
  let(:contrib) { ContributingLibrary.create! label: 'Lib 1', uri: 'http://example.org/lib' }

  before do
    assign(:book, book)
    assign(:version, Version.new)
  end

  it 'renders new version form' do
    render

    assert_select 'form[action=?][method=?]', book_versions_path(book), 'post' do
      expect(rendered).to have_unchecked_field 'version_based_on_original'
    end
  end
end
