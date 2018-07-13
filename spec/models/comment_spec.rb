require 'rails_helper'

RSpec.describe Comment, type: :model do
  subject(:comment) { described_class.new text: 'This is a comment', timestamp: DateTime.now.in_time_zone, entry_id: '1', user_id: '2' }

  it 'has properties' do
    expect(comment.text).to eq 'This is a comment'
    expect(comment.entry_id).to eq 1
    expect(comment.user_id).to eq 2
  end
end
