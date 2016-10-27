# coding: utf-8
# frozen_string_literal: true
require 'rails_helper'

describe Cicognara::TEIIndexer do
  before(:all) do
    Book.destroy_all
    Entry.destroy_all
    pathtotei = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml')
    pathtomarc = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml')
    @subject = described_class.new(pathtotei, pathtomarc)
  end

  after(:all) { Book.destroy_all }
  describe '#catalogo' do
    it 'has an associated tei file' do
      expect(@subject.catalogo.class).to eq(Nokogiri::XML::Document)
    end
  end

  describe '#books' do
    it 'builds the same index as if #to_solr was called' do
      expect(@subject.books[0].to_solr).to eq @subject.solr_docs[0]
      expect(@subject.solr_docs[4]).to eq @subject.entries[1].to_solr
    end
  end

  describe '#solr_docs' do
    it 'has a length of 8' do
      expect(@subject.solr_docs.length).to eq 8
    end
  end
end
