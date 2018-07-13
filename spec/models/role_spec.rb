require 'rails_helper'

RSpec.describe Role, type: :model do
  subject(:role) { described_class.create(label: 'author', uri: 'http://id.loc.gov/vocabulary/relators/aut') }

  it 'has a label' do
    expect(role.label).to eq('author')
  end

  it 'has a uri' do
    expect(role.uri).to eq('http://id.loc.gov/vocabulary/relators/aut')
  end

  context 'with a creator authority linked to the role relator' do
    subject(:role) { described_class.create(label: 'author', uri: 'http://id.loc.gov/vocabulary/relators/aut', creators: [creator]) }
    let(:creator) { Creator.create(label: "test creator") }

    it 'accesses the creators' do
      expect(role.creators).not_to be_empty
      expect(role.creators.first).to be_a Creator
      expect(role.creators.first.label).to eq 'test creator'
    end
  end
end
