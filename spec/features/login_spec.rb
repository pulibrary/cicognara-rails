require 'rails_helper'

RSpec.describe 'login', type: :feature do
  context 'when the user is logged in' do
    let(:admin) { stub_admin_user }

    before do
      allow(User).to receive(:from_omniauth).and_return(admin)
    end

    it 'is authorized' do
      OmniAuth.config.test_mode = true
      visit user_google_oauth2_omniauth_authorize_path
      expect(page).to have_current_path(root_path)
    end
  end

  context 'when the user is not logged in' do
    it 'allows viewing public pages' do
      visit root_path
      expect(page).to have_current_path(root_path)
    end
    it 'redirects login requests to google' do
      pending 'works in staging/prod but not in dev/test'
      visit root_path
      click_link('Log In')
      expect(page).to have_current_path(user_google_oauth2_omniauth_authorize_path)
    end
    it 'denies access to pages that require login' do
      OmniAuth.config.test_mode = true
      expect { visit users_path }.to raise_error(CanCan::AccessDenied)
    end
  end
end
