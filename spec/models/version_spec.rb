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
      owner_system_number: 'abc123',
      imported_metadata: { 'tei_title_txt' => 'a tei title', 'tei_author_txt' => 'an author' }
    }
  end

  before do
    stub_manifest('http://example.org/1.json')
  end

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

  it 'has an imported_metadata attribute' do
    expect(subject.imported_metadata).to include('tei_title_txt' => 'a tei title', 'tei_author_txt' => 'an author')
  end

  it 'validates attributes are present' do
    expect { described_class.create! attr.except(:based_on_original) }.to raise_error ActiveRecord::RecordInvalid
    expect { described_class.create! attr.except(:contributing_library) }.to raise_error ActiveRecord::RecordInvalid
    expect { described_class.create! attr.except(:label) }.to raise_error ActiveRecord::RecordInvalid
    expect { described_class.create! attr.except(:manifest) }.to raise_error ActiveRecord::RecordInvalid
    expect { described_class.create! attr.except(:owner_system_number) }.to raise_error ActiveRecord::RecordInvalid
    expect { described_class.create! attr.except(:rights) }.to raise_error ActiveRecord::RecordInvalid
  end

  it 'validates manifest is a url' do
    expect { described_class.create! attr.merge(manifest: 'foo') }.to raise_error ActiveRecord::RecordInvalid
  end

  it 'allows plain text rights statements' do
    new_attr = attr.except(:rights).merge(rights: 'All Rights Reserved')
    expect { described_class.create! new_attr }.not_to raise_error
  end

  describe '#manifest_url' do
    context "when there's only one owner system number with that version" do
      it 'returns the stored manifest' do
        subject.save!

        expect(subject.decorate.manifest_url).to eq 'http://example.org/1.json'
      end
    end

    context "when there's another owner system number with that version" do
      it 'returns a collection manifest URL of all combined versions' do
        subject.save!
        stub_manifest('http://example.org/2.json')
        described_class.create!(attr.merge(manifest: 'http://example.org/2.json'))

        expect(subject.decorate.manifest_url).to eq "http://test.host/versions/#{subject.id}/manifest"
      end
    end
  end
end
