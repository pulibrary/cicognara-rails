require 'rails_helper'

RSpec.describe 'Blacklight machinery', type: :feature do
  before { stub_admin_user }

  it 'has saved searches' do
    expect { visit '/saved_searches' }.not_to raise_error
  end

  it 'has search history' do
    expect { visit '/search_history' }.not_to raise_error
  end
end
