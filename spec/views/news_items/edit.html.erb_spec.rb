require 'rails_helper'

RSpec.describe 'news_items/edit', type: :view do
  let(:news_item) do
    NewsItem.create!(
      body: 'Body',
      title: 'Title',
      user_id: 1
    )
  end

  before do
    @news_item = assign(:news_item, news_item)
    render
  end

  it 'renders the edit news_item form' do
    assert_select 'form[action=?][method=?]', news_item_path(@news_item), 'post' do
      assert_select 'input#trix_input_news_item_1[name=?]', 'news_item[body]'
      assert_select 'input#news_item_title[name=?]', 'news_item[title]'
    end
  end
end
