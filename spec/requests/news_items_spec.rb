require 'rails_helper'

RSpec.describe 'NewsItems', type: :request do
  before { stub_admin_user }

  describe 'GET /news_items' do
    it 'shows a list of news items' do
      get news_items_path
      expect(response).to have_http_status(200)
    end
  end
end
