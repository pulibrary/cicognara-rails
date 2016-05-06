require 'rails_helper'

RSpec.describe 'ContributingLibrary', type: :request do
  before { stub_admin_user }

  describe 'GET /contributing_libraries' do
    it 'shows a list of versions' do
      get contributing_libraries_path
      expect(response).to have_http_status(200)
    end
  end
end
