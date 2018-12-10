require 'rails_helper'

RSpec.describe BookSubject, type: :model do
  subject(:book_subject) { described_class.new book: book, subject: subject }

  let(:marc_documents) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }
  let(:tei_documents) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml') }
  let(:solr_client) { Blacklight.default_index.connection }
  let(:tei_indexer) { Cicognara::TEIIndexer.new(tei_documents, marc_documents, solr_client) }
  let(:solr_documents) { tei_indexer.solr_docs }
  let(:book) { Book.first }
  let(:subject) { Subject.new label: 'puppies' }

  before do
    solr_client.add(solr_documents)
    solr_client.commit
  end

  it 'has a book and a subject' do
    expect(book_subject.book).to eq(book)
    expect(book_subject.subject).to eq(subject)
  end
end
