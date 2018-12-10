# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Entry, type: :model do
  subject(:entry) { c1d1e413 }

  let(:c1d1e413) { described_class.find_by(entry_id: 'c1d1e413') }
  let(:c1d1e444) { described_class.find_by(entry_id: 'c1d1e444') }
  let(:c1d1e818) { described_class.find_by(entry_id: 'c1d1e818') }

  before do
    stub_manifest('http://example.org/1.json')
    marc = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml')
    tei = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml')
    contrib = ContributingLibrary.find_or_create_by! label: 'Example Library', uri: 'http://example.org'

    solr = RSolr.connect(url: Blacklight.connection_config[:url])
    solr.add(Cicognara::TEIIndexer.new(tei, marc, solr).solr_docs)
    solr.commit

    book = Book.first
    Version.create!(contributing_library: contrib,
                    book: book,
                    label: 'version 2', based_on_original: false, owner_system_number: '1234',
                    rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
                    manifest: 'http://example.org/1.json')
  end

  describe '#entries' do
    it 'puts the n property in the database' do
      expect(entry.n_value).to eq entry.n
    end

    it 'has a correct n property' do
      expect(entry.n).to eq('1')
    end
  end

  describe '#corresp' do
    it 'has a corresp array' do
      expect(entry.corresp).to be_a Array
    end

    it 'is empty when there is no @corresp attr' do
      expect(entry.corresp.length).to eq 0
    end

    context 'when there is one value in @corresp' do
      subject(:entry) { c1d1e444 }

      it 'has length 1' do
        expect(entry.corresp.length).to eq 1
      end

      it 'has the right value' do
        expect(entry.corresp[0]).to eq('cico:m87')
      end
    end

    context 'when there are two values in @corresp' do
      subject(:entry) { c1d1e818 }

      it 'has length 2' do
        expect(entry.corresp.length).to eq 2
      end

      it 'has the right value' do
        expect(entry.corresp[1]).to eq('cico:98g')
      end
    end
  end

  describe '#text' do
    it 'is a string' do
      expect(entry.text.class).to eq(String)
    end
  end

  describe '#to_solr' do
    let(:solr_document) { entry.to_solr }

    it 'is a hash' do
      expect(entry.to_solr.class).to eq(Hash)
    end

    it 'has an id property' do
      expect(entry.to_solr[:id]).not_to be_nil
    end

    it 'has the right id property' do
      expect(solr_document[:id]).to eq('1')
    end

    it 'has a cico_s field' do
      expect(solr_document[:cico_s]).not_to be_nil
    end

    it 'has a cico_sort field' do
      expect(solr_document[:cico_s]).to eq '1'
    end

    it 'has the right cico_s field value' do
      expect(solr_document[:cico_s]).to eq('1')
    end

    it 'has a tei_description_unstem_search field' do
      expect(solr_document[:tei_description_unstem_search]).not_to be_nil
    end

    it 'has a tei_notes_txt field' do
      expect(solr_document[:tei_note_italian]).not_to be_nil
    end

    it 'does not have dclib_s field when @corresp is not present' do
      expect(solr_document[:dclib_s]).to be_nil
    end

    context 'when the entry has MARC 856$u field values' do
      let(:entry) { described_class.find_by(entry_id: 'c1d1e1398') }

      it 'indexes ARKs using the ark_s field' do
        expect(solr_document[:ark_s]).to eq(['ark:/88435/sb397c01j'])
      end
    end

    context 'when @corresp links to a MARC record' do
      subject(:entry) { c1d1e444 }

      it 'indexes 024$a values using the dclib_s field' do
        expect(solr_document[:dclib_s]).not_to be_nil
        expect(solr_document[:dclib_s]).to eq(['cico:m87'])
      end

      it 'indexes 024$a values using the dclib_display field' do
        expect(solr_document[:dclib_display]).to eq(['cico:m87'])
      end

      it 'indexes the MARC record XPath using the file_uri_s field' do
        expect(solr_document[:file_uri_s]).to eq("file://#{File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml')}//marc:record[0]")
      end
    end

    context 'when the corresp. has two values' do
      subject(:entry) { c1d1e818 }

      it 'dclib_s field has 2 values' do
        expect(solr_document[:dclib_s].length).to eq(2)
      end
    end

    it 'indexes the item number for display' do
      expect(solr_document[:title_display]).to include('Catalogo Item 1')
    end

    context 'when the entry has ' do
      subject(:entry) { c1d1e444 }

      it 'has a digitized content' do
        expect(solr_document[:digitized_version_available_facet]).to eq(['Matching copy'])
      end
    end

    describe 'marc-related fields' do
      context 'when corresp has one value' do
        subject(:entry) { c1d1e444 }

        it 'includes marc fields for indexing' do
          expect(solr_document[:title_addl_t]).to include('De incertitudine et vanitate scientiarum declamatio inuestiua')
        end

        it 'excludes marc fields for display' do
          expect(solr_document['title_addl_display']).to be_nil
        end
      end

      context 'when corresp has two values' do
        subject(:entry) { c1d1e818 }

        it 'is linked to two MARC records' do
          expect(entry.books.length).to eq 2
        end

        it 'keeps only single value for sort fields for entries with multiple marc records' do
          expect(solr_document[:pub_date]).to eq(1541)
        end

        it 'merges fields across multiple marc records' do
          expect(solr_document).to include(:subject_topic_facet)
          expect(solr_document[:subject_topic_facet]).to include('Humanism')
          expect(solr_document[:subject_topic_facet]).to include('Conduct of life')
        end
      end
    end
  end
end
