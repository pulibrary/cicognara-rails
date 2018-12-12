require 'rails_helper'

RSpec.describe NewsItem, type: :model do
  subject(:news_item) { described_class.new title: 'News item title', body: 'News item body', timestamp: DateTime.now.in_time_zone, user_id: '2' }

  it 'has properties' do
    expect(news_item.title).to eq 'News item title'
    expect(news_item.body).to eq 'News item body'
    expect(news_item.user_id).to eq 2
  end
end
