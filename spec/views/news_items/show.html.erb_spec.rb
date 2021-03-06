require 'rails_helper'

RSpec.describe 'news_items/show', type: :view do
  let(:news_item) do
    NewsItem.create!(
      body: 'Body',
      title: 'Title',
      user_id: user.id
    )
  end
  let(:user) { stub_admin_user }

  before do
    @news_item = assign(:news_item, news_item)
    render
  end

  it 'renders attributes in <p>' do
    expect(rendered).to match(/Body/)
    expect(rendered).to match(/Title/)
  end
end
