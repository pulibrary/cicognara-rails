# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Entry, type: :model do
  before(:all) do
    marc = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml')
    tei = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml')
    book = Book.find_or_create_by! digital_cico_number: 'cico:m87'
    Version.create! contributing_library: ContributingLibrary.first, book: book,
                    label: 'version 2', based_on_original: false, owner_system_number: '1234',
                    rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
                    manifest: 'http://example.org/1.json'

    solr = RSolr.connect(url: Blacklight.connection_config[:url])
    solr.add(Cicognara::TEIIndexer.new(tei, marc).solr_docs)
    solr.commit
  end
  subject { described_class.first }

  describe '#entries' do
    it 'has an n property' do
      expect(subject.n).not_to be_nil
    end

    it 'puts the n property in the database' do
      expect(subject.n_value).to eq subject.n
    end

    it 'has a correct n property' do
      expect(subject.n).to eq('1')
    end

    describe '#corresp' do
      it 'has a corresp array' do
        expect(subject.corresp.class).to eq(Array)
      end

      it 'is empty when there is no @corresp attr' do
        expect(subject.corresp.length).to eq 0
      end

      context 'when there is one value in @corresp' do
        subject { described_class.second }

        it 'has length 1' do
          expect(subject.corresp.length).to eq 1
        end

        it 'has the right value' do
          expect(subject.corresp[0]).to eq('cico:m87')
        end
      end

      context 'when there are two values in @corresp' do
        subject { described_class.third }

        it 'has length 2' do
          expect(subject.corresp.length).to eq 2
        end

        it 'has the right value' do
          expect(subject.corresp[1]).to eq('cico:98g')
        end
      end
    end

    describe '#text' do
      it 'is a string' do
        expect(subject.text.class).to eq(String)
      end
    end

    describe '#to_solr' do
      it 'is a hash' do
        expect(subject.to_solr.class).to eq(Hash)
      end

      it 'has an id property' do
        expect(subject.to_solr[:id]).not_to be_nil
      end

      it 'has the right id property' do
        expect(subject.to_solr[:id]).to eq('1')
      end

      it 'has a cico_s field' do
        expect(subject.to_solr[:cico_s]).not_to be_nil
      end

      it 'has a cico_sort field' do
        expect(subject.to_solr[:cico_s]).to eq '1'
      end

      it 'has the right cico_s field value' do
        expect(subject.to_solr[:cico_s]).to eq('1')
      end

      it 'has a tei_description_unstem_search field' do
        expect(subject.to_solr[:tei_description_unstem_search]).not_to be_nil
      end

      it 'has a tei_notes_txt field' do
        expect(subject.to_solr[:tei_note_italian]).not_to be_nil
      end

      it 'does not have dclib_s field when @corresp is not present' do
        expect(subject.to_solr[:dclib_s]).to be_nil
      end

      context 'when corresp is present' do
        subject { described_class.second }

        it 'has dclib_s field' do
          expect(subject.to_solr[:dclib_s]).not_to be_nil
        end

        it 'has the right value for the dclib_s field' do
          expect(subject.to_solr[:dclib_s].first).to eq('cico:m87')
        end

        it 'indexes the item number for display' do
          expect(subject.to_solr[:title_display]).to include('2')
        end

        it 'has a digitized content' do
          expect(subject.to_solr['digitized_version_available_facet']).to eq('True')
        end
      end
      context 'when corresp has 2 values' do
        subject { described_class.third }

        it 'dclib_s field has 2 values' do
          expect(subject.to_solr[:dclib_s].length).to eq(2)
        end
      end
    end

    describe 'marc-related fields' do
      context 'when corresp has one value' do
        subject { described_class.second }

        it 'includes marc fields for indexing' do
          expect(subject.to_solr['title_addl_t']).to include('De incertitudine et vanitate scientiarum declamatio inuestiua')
        end

        it 'excludes marc fields for display' do
          expect(subject.to_solr['title_addl_display']).to be_nil
        end
      end

      context 'when corresp has two values' do
        subject { described_class.third }

        it 'keeps only single value for sort fields for entries with multiple marc records' do
          expect(subject.to_solr['pub_date']).to eq(1541)
        end

        it 'merges fields across multiple marc records' do
          expect(subject.to_solr['subject_topic_facet']).to include('Humanism')
          expect(subject.to_solr['subject_topic_facet']).to include('Conduct of life')
        end
      end
    end
  end
end
