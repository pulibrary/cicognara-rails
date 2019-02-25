require 'rails_helper'

RSpec.describe 'news_items/index', type: :view do
  let(:item_1) do
    NewsItem.create!(
      body: 'Body',
      title: 'Title',
      timestamp: DateTime.current,
      user_id: user.id
    )
  end

  let(:item_2) do
    NewsItem.create!(
      body: 'Body',
      title: 'Title',
      timestamp: DateTime.current,
      user_id: user.id
    )
  end
  let(:user) { stub_admin_user }

  before do
    assign(:news_items, [item_1, item_2])
    render
  end

  it 'renders a list of news_items' do
    expect(rendered).to have_css 'h2.news-item-title', text: 'Title'.to_s, count: 2
    expect(rendered).to have_css 'div.news-item-body', text: 'Body'.to_s, count: 2
    expect(rendered).to have_css 'p.dateline', count: 2
  end
end
