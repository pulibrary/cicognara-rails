require 'rails_helper'

RSpec.describe 'errors/not_found.html.erb', type: :view do
  it 'displays an error message' do
    render

    expect(rendered).to have_selector 'h2.error', text: 'Not Found'
  end
end
