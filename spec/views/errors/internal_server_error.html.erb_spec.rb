require 'rails_helper'

RSpec.describe 'errors/internal_server_error.html.erb', type: :view do
  it 'displays an error message' do
    render

    expect(rendered).to have_selector 'h2.error', text: 'Internal Server Error'
  end
end
