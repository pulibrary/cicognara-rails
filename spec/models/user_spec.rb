require 'rails_helper'

RSpec.describe User, type: :model do
  subject { described_class.new email: 'alice@example.org', role: 'admin' }

  it 'uses the email address for display' do
    expect(subject.to_s).to eq('alice@example.org')
  end

  it 'has a role' do
    expect(subject.role).to eq('admin')
  end

  it 'is admin' do
    expect(subject.admin?).to be true
  end

  it 'can change the role' do
    subject.role = 'curator'
    expect(subject.role).to eq('curator')
  end
end
