require 'spec_helper'

RSpec.describe User, type: :model do
  subject { described_class.new email: 'alice@example.org' }

  it 'uses the email address for display' do
    expect(subject.to_s).to eq('alice@example.org')
  end
end
