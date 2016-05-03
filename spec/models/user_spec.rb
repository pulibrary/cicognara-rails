require 'rails_helper'

RSpec.describe User, type: :model do
  subject { User.new email: 'alice@example.org' }

  it 'uses the email address for display' do
    expect(subject.to_s).to eq('alice@example.org')
  end
end
