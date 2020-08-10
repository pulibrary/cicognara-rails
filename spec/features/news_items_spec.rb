require 'rails_helper'

RSpec.describe 'News Items', type: :feature do
  let(:user) { User.create! email: 'user@example.org', role: 'curator' }
  let(:news_item) { NewsItem.create! title: 'News item title', body: 'News item body', user_id: user.id, timestamp: DateTime.now.in_time_zone }

  before do
    news_item
  end

  context 'with a logged in admin user' do
    before do
      stub_admin_user
    end

    it 'displays news items with links for creating, editing, and deleting' do
      visit news_items_url
      expect(page).to have_css 'input.news-item-add-button'
      expect(page).to have_selector 'h2.news-item-title', text: 'News item title'
      expect(page).to have_link 'Edit', href: edit_news_item_path(news_item.id)
      expect(page).to have_link 'Destroy', href: news_item_path(news_item.id)
    end
  end

  context 'with a non-admin user' do
    before do
      stub_public_user
    end

    it 'displays news items without links for creating, editing, and deleting' do
      visit news_items_url
      expect(page).not_to have_css 'input.news-item-add-button'
      expect(page).to have_selector 'h2.news-item-title', text: 'News item title'
      expect(page).not_to have_link 'Edit', href: edit_news_item_path(news_item.id)
      expect(page).not_to have_link 'Destroy', href: news_item_path(news_item.id)
    end
  end
end
