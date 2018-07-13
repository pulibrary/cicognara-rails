require 'rails_helper'

RSpec.describe Creator, type: :model do
  subject(:creator) { described_class.create(label: 'Alice', uri: 'http://id.loc.gov/authorities/names/n88194580') }

  it 'has a label' do
    expect(creator.label).to eq('Alice')
  end

  it 'has a uri' do
    expect(creator.uri).to eq('http://id.loc.gov/authorities/names/n88194580')
  end

  context 'with a role relator linked to the authority' do
    subject(:creator) { described_class.create(label: 'Alice', uri: 'http://id.loc.gov/authorities/names/n88194580', roles: [role]) }
    let(:role) { Role.create(label: "test role") }

    it 'accesses the roles' do
      expect(creator.roles).not_to be_empty
      expect(creator.roles.first).to be_a Role
      expect(creator.roles.first.label).to eq 'test role'
    end
  end
end
