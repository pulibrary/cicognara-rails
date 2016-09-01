# coding: utf-8
require 'rails_helper'
require 'tei_helper'

describe TEIIndexer do
  subject { described_class.new(pathtotei, pathtoxsl, pathtomarc) }
  let(:pathtotei) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml') }
  let(:pathtomarc) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }
  let(:pathtoxsl) { File.join(File.dirname(__FILE__), '../..', 'lib', 'xsl', 'catalogo-item-to-html.xsl') }

  after(:all) { Book.destroy_all }
  describe '#catalogo' do
    it 'has an associated tei file' do
      expect(subject.catalogo.class).to eq(Nokogiri::XML::Document)
    end
  end

  describe '#items' do
    it 'has a length of 3' do
      expect(subject.items.length).to eq 5
    end

    it 'has an n property' do
      expect(subject.items.first.n).not_to be_nil
    end

    it 'has a correct n property' do
      expect(subject.items.first.n).to eq('1')
    end

    describe '#corresp' do
      it 'has a corresp array' do
        expect(subject.items.first.corresp.class).to eq(Array)
      end

      it 'is empty when there is no @corresp attr' do
        expect(subject.items.first.corresp.length).to eq 0
      end

      it 'has length 1 when there is one value in @corresp' do
        expect(subject.items[1].corresp.length).to eq 1
      end

      it 'has the right value' do
        expect(subject.items[1].corresp[0]).to eq('cico:m87')
      end

      it 'has length 2 when there are two values in @corresp' do
        expect(subject.items[2].corresp.length).to eq 2
      end

      it 'has the right value' do
        expect(subject.items[2].corresp[1]).to eq('cico:98g')
      end
    end

    describe '#text' do
      it 'is a string' do
        expect(subject.items.first.text.class).to eq(String)
      end
    end

    describe '#html' do
      it 'begin with <p> and end with </p>' do
        expect(%r{^<p>.*</p>$}m =~ subject.items.first.html).to eq(0)
      end
    end

    describe '#solr_doc' do
      it 'is a hash' do
        expect(subject.items.first.solr_doc.class).to eq(Hash)
      end

      it 'has an id property' do
        expect(subject.items.first.solr_doc[:id]).not_to be_nil
      end

      it 'has the right id property' do
        expect(subject.items.first.solr_doc[:id]).to eq('1')
      end

      it 'has a cico_s field' do
        expect(subject.items.first.solr_doc[:cico_s]).not_to be_nil
      end

      it 'has the right cico_s field value' do
        expect(subject.items.first.solr_doc[:cico_s]).to eq('1')
      end

      it 'has a description_t field' do
        expect(subject.items.first.solr_doc[:description_t]).not_to be_nil
      end

      it 'has a description_display field' do
        expect(subject.items.first.solr_doc[:description_display]).not_to be_nil
      end

      it 'does not have dclib_s field when @corresp is not present' do
        expect(subject.items.first.solr_doc[:dclib_s]).to be_nil
      end

      it 'has dclib_s field when @corresp is present' do
        expect(subject.items[1].solr_doc[:dclib_s]).not_to be_nil
      end

      it 'has the right value for the dclib_s field' do
        expect(subject.items[1].solr_doc[:dclib_s].first).to eq('cico:m87')
      end

      it 'dclib_s field to have 2 values when @corresp has 2 values' do
        expect(subject.items[2].solr_doc[:dclib_s].length).to eq(2)
      end

      it 'indexes the section number and item number for display' do
        expect(subject.items[1].solr_doc[:title_display]).to include('1.1', '2')
      end
    end

    describe 'marc-related fields' do
      it 'includes marc fields for indexing' do
        expect(subject.items[1].solr_doc['title_addl_t']).to include('De incertitudine et vanitate scientiarum declamatio inuestiua')
      end

      it 'excludes marc fields for display' do
        expect(subject.items[1].solr_doc['title_addl_display']).to be_nil
      end

      it 'keeps only single value for sort fields for entries with multiple marc records' do
        expect(subject.items[2].solr_doc['pub_date']).to eq(1541)
      end

      it 'merges fields across multiple marc records' do
        expect(subject.items[2].solr_doc['subject_topic_facet']).to include('Humanism')
        expect(subject.items[2].solr_doc['subject_topic_facet']).to include('Conduct of life')
      end
    end
  end

  describe '#solr_docs' do
    it 'has a length of 5' do
      expect(subject.solr_docs.length).to eq 5
    end
  end
end
