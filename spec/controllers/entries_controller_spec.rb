require 'rails_helper'

RSpec.describe EntriesController do
  describe '#manifest' do
    it 'returns a manifest for an entry based on n value' do
      e = Entry.create!(n_value: '1')

      get :manifest, params: { id: e.n_value, format: :json }

      expect(response).to be_success
      e.destroy
    end
  end
end
