require 'rails_helper'

RSpec.describe "searching", type: :feature do
  it 'performs a search' do
    visit '/catalog?q='
    expect(page.status_code).to eq(200)
  end
end
