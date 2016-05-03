require 'rails_helper'

RSpec.describe Subject, type: :model do
  subject { described_class.new label: 'puppies', uri: 'http://id.loc.gov/authorities/subjects/sh85109152' }

  it 'has a label' do
    expect(subject.label).to eq('puppies')
  end

  it 'has a uri' do
    expect(subject.uri).to eq('http://id.loc.gov/authorities/subjects/sh85109152')
  end
end
