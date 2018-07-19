# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Entry, type: :model do
  subject(:entry) { described_class.create(tei: teixml, n_value: '15', books: [book]) }

  let(:digital_cico_number) { 'xyz' }
  let(:contributing_library) { ContributingLibrary.create(label: 'Example Library', uri: 'http://www.example.org') }
  let(:iiif_manifest) { IIIF::Manifest.create(uri: 'http://example.org/1.json', label: 'Version 1') }
  let(:version) do
    Version.create(
      contributing_library: contributing_library,
      label: 'version 2',
      based_on_original: true,
      owner_system_number: '1234',
      rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
      iiif_manifest: iiif_manifest
    )
  end
  let(:volume) { Volume.create(digital_cico_number: digital_cico_number, versions: [version]) }
  let(:marc_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }
  let(:marcxml) { File.open(marc_path) { |f| Nokogiri::XML(f) } }
  let(:file_uri) { 'file:///test.mrx//marc:record[0]' }
  let(:marc_record) { MarcRecord.create(source: marcxml, file_uri: file_uri) }
  let(:book) { Book.create(volumes: [volume], marc_record: marc_record) }

  # let(:teixml) { File.open(tei_path) { |f| Nokogiri::XML(f) } }
  # teixml.xpath("//tei:item", "tei": "http://www.tei-c.org/ns/1.0").length
  let(:teixml) do
    document = File.open(tei_path) { |f| Nokogiri::XML(f) }
    document.xpath('//tei:item', "tei": 'http://www.tei-c.org/ns/1.0')
  end
  let(:tei_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml') }

  before do
    #     marc = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml')
    #     tei = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml')
    #     book = Book.find_or_create_by(digital_cico_number: 'cico:m87')
    #     contrib = ContributingLibrary.find_or_create_by! label: 'Example Library', uri: 'http://example.org'
    #     Version.create(
    #       contributing_library: contrib,
    #       #book: book,
    #       label: 'version 2', based_on_original: false, owner_system_number: '1234',
    #       rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
    #       #manifest: 'http://example.org/1.json'
    #     )
    #
    #     solr = RSolr.connect(url: Blacklight.connection_config[:url])
    #     solr.add(Cicognara::TEIIndexer.new(tei, marc).solr_docs)
    #     solr.commit
    solr = RSolr.connect(url: Blacklight.connection_config[:url])
    # solr.add(Cicognara::TEIIndexer.new(tei_path, marc_path).solr_docs)
    solr.commit
  end

  let(:solr_docs) do
    # solr = RSolr.connect(url: Blacklight.connection_config[:url])
    # docs = #solr.add(Cicognara::TEIIndexer.new(tei_path, marc_path).solr_docs)
    # solr.commit
    Cicognara::TEIIndexer.new(tei_path, marc_path).solr_docs
  end

  describe '#entries' do
    before do
      # solr_docs
    end
    it 'has an n property' do
      # binding.pry
      expect(entry.n).not_to be_nil
    end

    it 'puts the n property in the database' do
      expect(entry.n_value).to eq entry.n
    end

    it 'has a correct n property' do
      # binding.pry
      expect(entry.n).to eq('1')
    end

    describe '#corresp' do
      it 'has a corresp array' do
        expect(entry.corresp.class).to eq(Array)
      end

      it 'is empty when there is no @corresp attr' do
        expect(entry.corresp.length).to eq 0
      end

      context 'when there is one value in @corresp' do
        subject(:entry) { described_class.create(tei: teixml[1], n_value: '2', books: [book]) }

        it 'has length 1' do
          expect(entry.corresp.length).to eq 1
        end

        it 'has the right value' do
          expect(entry.corresp[0]).to eq('cico:m87')
        end
      end

      context 'when there are two values in @corresp' do
        subject(:entry) { described_class.create(tei: teixml[2], n_value: '15', books: [book]) }

        let(:marc_record) do
          MarcRecord.resolve(
            'file://' + File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') + '//marc:record[1]'
          )
        end
        let(:marc_record_2) do
          MarcRecord.resolve(
            'file://' + File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') + '//marc:record[2]'
          )
        end
        let(:book) { Book.create(volumes: [volume], marc_record: marc_record) }
        let(:book_2) { Book.create(volumes: [volume], marc_record: marc_record_2) }

        # let(:entry) { Entry.create(tei: teixml, n_value: '15', books: [book, book_2]) }

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
      it 'is a hash' do
        expect(entry.to_solr.class).to eq(Hash)
      end

      it 'has an id property' do
        expect(entry.to_solr[:id]).not_to be_nil
      end

      it 'has the right id property' do
        expect(entry.to_solr[:id]).to eq('1')
      end

      it 'has a cico_s field' do
        expect(entry.to_solr[:cico_s]).not_to be_nil
      end

      it 'has a cico_sort field' do
        expect(entry.to_solr[:cico_s]).to eq '1'
      end

      it 'has the right cico_s field value' do
        expect(entry.to_solr[:cico_s]).to eq('1')
      end

      it 'has a tei_description_unstem_search field' do
        expect(entry.to_solr[:tei_description_unstem_search]).not_to be_nil
      end

      it 'has a tei_notes_txt field' do
        expect(entry.to_solr[:tei_note_italian]).not_to be_nil
      end

      it 'does not have dclib_s field when @corresp is not present' do
        expect(entry.to_solr[:dclib_s]).to be_nil
      end

      context 'when corresp is present' do
        subject(:entry) { described_class.create(tei: teixml[1], n_value: '2', books: [book]) }

        it 'has dclib_s field' do
          expect(entry.to_solr[:dclib_s]).not_to be_nil
        end

        it 'has the right value for the dclib_s field' do
          expect(entry.to_solr[:dclib_s].first).to eq('cico:m87')
        end

        it 'indexes the item number for display' do
          expect(entry.to_solr[:title_display]).to include('2')
        end

        it 'has a digitized content' do
          expect(entry.to_solr['digitized_version_available_facet']).to eq('Yes')
        end
      end
      context 'when corresp has 2 values' do
        subject(:entry) { described_class.create(tei: teixml[2], n_value: '15', books: [book]) }

        it 'dclib_s field has 2 values' do
          solr_docs = entry.to_solr
          expect(solr_docs[:dclib_s].length).to eq(2)
        end
      end
    end

    describe 'marc-related fields' do
      context 'when corresp has one value' do
        subject(:entry) { described_class.create(tei: teixml, n_value: '2', books: [book]) }

        let(:marc_record) do
          MarcRecord.resolve(
            'file://' + File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') + '//marc:record[0]'
          )
        end

        it 'includes marc fields for indexing' do
          # binding.pry
          expect(entry.to_solr['title_addl_t']).to include('De incertitudine et vanitate scientiarum declamatio inuestiua')
        end

        it 'excludes marc fields for display' do
          expect(entry.to_solr['title_addl_display']).to be_nil
        end
      end

      context 'when corresp has two values' do
        subject(:entry) { described_class.create(tei: teixml[2], n_value: '15', books: [book]) }

        let(:marc_record) do
          MarcRecord.resolve(
            'file://' + File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') + '//marc:record[1]'
          )
        end

        it 'keeps only single value for sort fields for entries with multiple marc records' do
          solr_doc = entry.to_solr
          expect(solr_doc['pub_date']).to eq(1541)
        end

        describe '#to_solr' do
          let(:marc_record) do
            MarcRecord.resolve(
              'file://' + File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') + '//marc:record[1]'
            )
          end
          let(:marc_record_2) do
            MarcRecord.resolve(
              'file://' + File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') + '//marc:record[2]'
            )
          end
          let(:book) { Book.create(volumes: [volume], marc_record: marc_record) }
          let(:book_2) { Book.create(volumes: [volume], marc_record: marc_record_2) }
          let(:entry) { Entry.create(tei: teixml, n_value: '15', books: [book, book_2]) }

          let(:solr_document) { entry.to_solr }

          it 'merges fields across multiple marc records' do
            # solr_document = entry.to_solr

            expect(solr_document).to include('subject_topic_facet')
            expect(solr_document['subject_topic_facet']).to include('Humanism')
            expect(solr_document['subject_topic_facet']).to include('Conduct of life')
          end
        end
      end
    end
  end
end
