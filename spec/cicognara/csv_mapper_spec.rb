# coding: utf-8
require 'rails_helper'
require 'csv'
require './lib/cicognara/csv_mapper.rb'

describe Cicognara::CSVMapper do
  let(:good_csv) { load_csv 'sample_good.csv' }
  let(:bad_book_csv) { load_csv 'sample_bad_book.csv' }
  let(:bad_contrib_csv) { load_csv 'sample_bad_contrib.csv' }
  let(:marc_documents) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }
  let(:tei_documents) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml') }
  let(:solr_client) { Blacklight.default_index.connection }
  let(:tei_indexer) { Cicognara::TEIIndexer.new(tei_documents, marc_documents, solr_client) }
  let(:solr_documents) { tei_indexer.solr_docs }

  before do
    solr_client.add(solr_documents)
    solr_client.commit
    @book = Book.first

    @contrib = ContributingLibrary.create label: 'Contributor 1', uri: 'http://example.org/'
  end

  describe 'good sample' do
    subject(:results) { described_class.map(good_csv) }

    it 'maps book and contributing library' do
      expect(subject[:book]).to eq @book
      expect(subject[:contributing_library]).to eq @contrib
    end

    it 'maps based_on_original' do
      expect(subject[:based_on_original]).to be false
    end
  end

  describe 'bad book reference' do
    it 'rasies an argument error' do
      expect { described_class.map(bad_book_csv) }.to raise_error(ArgumentError, "Book not found 'xyz'")
    end
  end

  describe 'bad contributing library reference' do
    it 'rasies an argument error' do
      expect { described_class.map(bad_contrib_csv) }.to raise_error(ArgumentError, "ContributingLibrary not found 'xyz'")
    end
  end
end

def load_csv(fn)
  CSV.read(File.join(File.dirname(__FILE__), '..', 'fixtures', fn), headers: true).first.to_h
end
