require 'rails_helper'

RSpec.describe Version, type: :model do
  subject { described_class.new attr }

  let(:contributing_library) { ContributingLibrary.new label: 'Example Library' }
  let(:marc_documents) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }
  let(:tei_documents) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml') }
  let(:solr_client) { Blacklight.default_index.connection }
  let(:tei_indexer) { Cicognara::TEIIndexer.new(tei_documents, marc_documents) }
  let(:solr_documents) { tei_indexer.solr_docs }
  let(:book) { Book.first }
  let(:attr) do
    {
      contributing_library: contributing_library,
      book: book,
      label: 'version 2',
      based_on_original: true,
      manifest: 'http://example.org/manifest.json',
      rights: 'https://creativecommons.org/publicdomain/mark/1.0/',
      owner_system_number: 'abc123'
    }
  end

  before do
    solr_client.add(solr_documents)
    solr_client.commit
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
end
