require 'rails_helper'

RSpec.describe ApplicationController do
  describe '#current_user' do
    it 'is the first user in development' do
      u = User.create!(email: 'test@test.com', role: 'admin')
      allow(Rails.env).to receive(:development?).and_return(true)

      expect(controller.current_user).to eq u
    end
  end
end
