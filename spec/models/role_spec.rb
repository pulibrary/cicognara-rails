require 'rails_helper'

RSpec.describe Role, type: :model do
  subject { described_class.new label: 'author', uri: 'http://id.loc.gov/vocabulary/relators/aut' }

  it 'has a label' do
    expect(subject.label).to eq('author')
  end

  it 'has a uri' do
    expect(subject.uri).to eq('http://id.loc.gov/vocabulary/relators/aut')
  end
end
