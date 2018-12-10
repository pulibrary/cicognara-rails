# frozen_string_literal: true

require 'rails_helper'

describe Cicognara::BulkEntryIndexer do
  subject(:bulk_entry_indexer) { described_class.new(entries, index) }

  let(:entry) { instance_double(Entry) }
  let(:entries) { [entry] }
  let(:index) { instance_double(RSolr::Client) }
  let(:cache) do
    {}
  end
  let(:books_cache) do
    {}
  end
  let(:solr_doc1) do
    {}
  end
  let(:solr_doc2) do
    {}
  end
  let(:marc_document) { Nokogiri::XML::Document.new }
  let(:marc_record1) { instance_double(MarcRecord) }
  let(:marc_record2) { instance_double(MarcRecord) }
  let(:book1) { instance_double(Book) }
  let(:book2) { instance_double(Book) }
  # This cannot be an instance_double due to the delegation of certain methods
  # rubocop:disable RSpec/VerifiedDoubles
  let(:with_book_cache) { double('with_book_cache') }
  # rubocop:enable RSpec/VerifiedDoubles
  let(:with_book_cache_class) { class_double(Cicognara::WithBookCache).as_stubbed_const(transfer_nested_constants: true) }

  before do
    allow(marc_record2).to receive(:file_uri).and_return('file://document.mrx//record[0]')
    allow(marc_record1).to receive(:file_uri).and_return('file://document.mrx//record[0]')
    allow(marc_record2).to receive(:source).and_return(marc_document)
    allow(marc_record2).to receive(:reload)
    allow(marc_record1).to receive(:source).and_return(marc_document)
    allow(marc_record1).to receive(:reload)
    allow(book1).to receive(:marc_record).and_return(marc_record1)
    allow(book1).to receive(:id).and_return(1)
    allow(book2).to receive(:id).and_return(2)
    allow(book1).to receive(:to_solr).and_return(solr_doc1)
    allow(book2).to receive(:marc_record).and_return(marc_record2)
    allow(book2).to receive(:to_solr).and_return(solr_doc2)
    allow(entry).to receive(:item_titles).and_return(['test entry'])
    allow(entry).to receive(:books).and_return([book1, book2])
    allow(entry).to receive(:id).and_return(1)
    allow(index).to receive(:add)
    allow(index).to receive(:commit)
    allow(with_book_cache).to receive(:to_solr).and_return([solr_doc1, solr_doc2])
    allow(with_book_cache_class).to receive(:new).and_return(with_book_cache)
  end

  describe '#index' do
    before do
      bulk_entry_indexer.index
    end
    it 'indexes the documents' do
      expect(with_book_cache_class).to have_received(:new).with(entry, {})
      expect(index).to have_received(:add).with([solr_doc1, solr_doc2])
    end
  end
end
