require 'rails_helper'

RSpec.describe 'news_items/new', type: :view do
  let(:news_item) do
    NewsItem.new(
      body: 'Body',
      title: 'Title',
      user_id: 1
    )
  end

  before do
    assign(:news_item, news_item)
    render
  end

  it 'renders new news_item form' do
    assert_select 'form[action=?][method=?]', news_items_path, 'post' do
      assert_select 'input#news_item_title[name=?]', 'news_item[title]'
      assert_select 'input#trix_input_news_item[name=?]', 'news_item[body]'
    end
  end
end
