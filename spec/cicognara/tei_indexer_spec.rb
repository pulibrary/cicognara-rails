require 'rails_helper'
require 'tei_helper'

describe TEIIndexer do
  subject { described_class.new(pathtotei) }
  let(:pathtotei) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml') }

  describe '#catalogo' do
    it 'has an associated tei file' do
      expect(subject.catalogo.class).to eq(Nokogiri::XML::Document)
    end
  end

  describe '#items' do
    it 'has a length of 3' do
      expect(subject.items.length).to eq 3
    end

    it 'has an id property' do
      expect(subject.items.first.id).not_to be_nil
    end

    it 'id is a string' do
      expect(subject.items.first.id.class).to eq(String)
    end

    it 'has a correct id property' do
      expect(subject.items.first.id).to eq('c1d1e413')
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

    describe '#solr_doc' do
      it 'is a hash' do
        expect(subject.items.first.solr_doc.class).to eq(Hash)
      end

      it 'has an id property' do
        expect(subject.items.first.solr_doc[:id]).not_to be_nil
      end

      it 'has the right id property' do
        expect(subject.items.first.solr_doc[:id]).to eq('c1d1e413')
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
    end
  end

  describe '#solr_docs' do
    it 'has a length of 3' do
      expect(subject.solr_docs.length).to eq 3
    end
  end
end
