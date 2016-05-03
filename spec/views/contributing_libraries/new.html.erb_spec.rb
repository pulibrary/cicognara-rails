require 'rails_helper'

RSpec.describe 'contributing_libraries/new', type: :view do
  before do
    assign(:contributing_library, ContributingLibrary.new)
  end

  it 'renders new contributing_library form' do
    render

    assert_select 'form[action=?][method=?]', contributing_libraries_path, 'post' do
    end
  end
end
