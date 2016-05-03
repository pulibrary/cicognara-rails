require 'rails_helper'

RSpec.describe CreatorRole, type: :model do
  let(:creator) { Creator.new label: 'Alice' }
  let(:role) { Role.new label: 'author' }
  subject { described_class.new creator: creator, role: role }

  it 'has a creator' do
    expect(subject.creator).to eq(creator)
  end

  it 'has a role' do
    expect(subject.role).to eq(role)
  end
end
