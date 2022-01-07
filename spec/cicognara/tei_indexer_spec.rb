# coding: utf-8
# frozen_string_literal: true
require 'rails_helper'

describe Cicognara::TEIIndexer do
  before do
    stub_manifest('http://example.org/1.json')
  end

  before(:all) do
    pathtotei = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml')
    pathtomarc = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml')
    @subject = described_class.new(pathtotei, pathtomarc)
  end

  describe '#catalogo' do
    it 'has an associated tei file' do
      expect(@subject.catalogo.class).to eq(Nokogiri::XML::Document)
    end
  end

  describe '#books' do
    it 'builds the same index as if #to_solr was called' do
      expect(@subject.books[0].to_solr).to eq @subject.solr_docs[0]
      expect(@subject.solr_docs[6]).to eq @subject.entries[0].to_solr
    end

    it 'prefers the year in TEI over the year in MARC for catalog items' do
      # Notice that we evaluate against the same Cigonara ID from MARC and from TEI.
      marc_record = @subject.solr_docs.find { |x| x['cico_id_t'] == ['2'] }
      expect(marc_record['pub_date']).to eq [1600]

      catalog_item = @subject.solr_docs.find { |x| x[:cico_s] == '2' }
      expect(catalog_item['pub_date']).to eq 1584
    end
  end

  describe '#solr_docs' do
    it 'has a length of 13' do
      expect(@subject.solr_docs.length).to eq 13
    end
  end
end
