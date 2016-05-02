require 'rails_helper'

RSpec.describe Version, type: :model do
  let(:contributing_library) { ContributingLibrary.new label: 'Example Library' }
  let(:book) { Book.new digital_cico_number: 'xyz' }
  subject {
    described_class.new contributing_library: contributing_library, book: book,
        label: 'version 2', based_on_original: true
  }

  it 'has a contributor' do
    expect(subject.contributing_library).to eq(contributing_library)
  end

  it 'has a book' do
    expect(subject.book).to eq(book)
  end

  it 'has a label' do
    expect(subject.label).to eq('version 2')
  end

  it 'has a based_on_original' do
    expect(subject.based_on_original).to be true
  end
end
