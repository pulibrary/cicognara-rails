# coding: utf-8
# frozen_string_literal: true
require 'rails_helper'

describe Cicognara::TEIIndexer do
  subject(:tei_indexer) { described_class.new(pathtotei, pathtomarc, index) }

  let(:pathtotei) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml') }
  let(:pathtomarc) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }
  let(:index) { Blacklight.default_index.connection }

  before do
    stub_manifest('http://example.org/1.json')
    tei_indexer
  end

  describe '#catalogo' do
    it 'has an associated tei file' do
      expect(tei_indexer.catalogo.class).to eq(Nokogiri::XML::Document)
    end
  end

  describe '#books' do
    it 'retrieves the books' do
      expect(tei_indexer.books.size).to eq(5)
      expect(tei_indexer.books.first).to be_a Book
      expect(tei_indexer.books.last).to be_a Book
    end
  end

  describe '#solr_docs' do
    it 'indexes all of the documents' do
      documents = tei_indexer.solr_docs
      expect(documents.length).to eq 13
    end
  end
end
