require 'rails_helper'

RSpec.describe ContributingLibrary, type: :model do
  subject { described_class.new label: 'Example Library', uri: 'http://example.org' }

  it 'has a label' do
    expect(subject.label).to eq('Example Library')
  end

  it 'has a uri' do
    expect(subject.uri).to eq('http://example.org')
  end
end
