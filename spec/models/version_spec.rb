require 'rails_helper'

RSpec.describe Version, type: :model do
  subject { described_class.new attr }

  let(:contributing_library) { ContributingLibrary.new label: 'Example Library' }
  let(:book) { Book.new digital_cico_number: 'xyz' }
  let(:attr) do
    {
      contributing_library: contributing_library,
      book: book,
      label: 'version 2',
      based_on_original: true,
      manifest: 'http://example.org/1.json',
      rights: 'https://creativecommons.org/publicdomain/mark/1.0/',
      owner_system_number: 'abc123'
    }
  end

  before do
    stub_manifest('http://example.org/1.json')
  end

  it 'has a contributor' do
    binding.pry
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

  it 'validates attributes are present' do
    expect { described_class.create! attr.except(:based_on_original) }.to raise_error ActiveRecord::RecordInvalid
    expect { described_class.create! attr.except(:contributing_library) }.to raise_error ActiveRecord::RecordInvalid
    expect { described_class.create! attr.except(:label) }.to raise_error ActiveRecord::RecordInvalid
    expect { described_class.create! attr.except(:manifest) }.to raise_error ActiveRecord::RecordInvalid
    expect { described_class.create! attr.except(:owner_system_number) }.to raise_error ActiveRecord::RecordInvalid
    expect { described_class.create! attr.except(:rights) }.to raise_error ActiveRecord::RecordInvalid
  end

  it 'validates manifest and rights are urls' do
    expect { described_class.create! attr.merge(manifest: 'foo') }.to raise_error ActiveRecord::RecordInvalid
    expect { described_class.create! attr.merge(rights: 'foo') }.to raise_error ActiveRecord::RecordInvalid
  end

  it 'queues a job to index ocr_text' do
    allow(PopulateVersionOCRJob).to receive(:perform_later)
    subject.save!
    # Ensure an update that doesn't touch manifest doesn't trigger a job
    subject.update(label: 'Update again')

    expect(PopulateVersionOCRJob).to have_received(:perform_later).with(subject).exactly(1).times
  end
end
