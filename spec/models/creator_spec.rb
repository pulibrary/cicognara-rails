require 'rails_helper'

RSpec.describe Creator, type: :model do
  subject(:creator) { FactoryBot.build(:creator) }

  it 'has a label' do
    expect(creator.label).to eq('Alice')
  end

  it 'has a uri' do
    expect(creator.uri).to eq('http://id.loc.gov/authorities/names/n88194580')
  end
end
