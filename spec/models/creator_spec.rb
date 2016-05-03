require 'rails_helper'

RSpec.describe Creator, type: :model do
  subject { described_class.new label: 'Alice', uri: 'http://id.loc.gov/authorities/names/n88194580' }

  it 'has a label' do
    expect(subject.label).to eq('Alice')
  end

  it 'has a uri' do
    expect(subject.uri).to eq('http://id.loc.gov/authorities/names/n88194580')
  end
end
