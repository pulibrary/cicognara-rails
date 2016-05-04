require 'rails_helper'

RSpec.describe 'contributing_libraries/edit', type: :view do
  let(:contributing_library) { ContributingLibrary.create!(label: 'Library 1', uri: 'http://example.org/1') }

  before do
    assign(:contributing_library, contributing_library)
  end

  after do
    contributing_library.destroy
  end

  it 'renders the edit contributing_library form' do
    render

    assert_select 'form[action=?][method=?]', contributing_library_path(contributing_library), 'post' do
    end
  end
end
