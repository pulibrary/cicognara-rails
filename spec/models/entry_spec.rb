# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Entry, type: :model do
  before do
    stub_manifest('http://example.org/1.json')
    contrib
    book
    version

    marc = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml')
    tei = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml')
    book1 = Book.find_or_create_by! digital_cico_number: 'cico:m87'
    contrib1 = ContributingLibrary.find_or_create_by! label: 'Example Library', uri: 'http://example.org'
    Version.create! contributing_library: contrib1, book: book1,
                    label: 'version 2', based_on_original: false, owner_system_number: '1234',
                    rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
                    manifest: 'http://example.org/1.json'

    solr = RSolr.connect(url: Blacklight.connection_config[:url])
    solr.add(Cicognara::TEIIndexer.new(tei, marc).solr_docs)
    solr.commit
  end
  subject(:entry) { FactoryBot.create(:entry) }

  let(:contrib) { FactoryBot.create(:contributing_library) }
  let(:book) { FactoryBot.create(:book, digital_cico_number: 'cico:m87') }
  let(:version) { FactoryBot.create(:version, contributing_library: contrib, book: book) }

  describe '#entries' do
    it 'has an n property' do
      expect(entry.n).not_to be_nil
    end

    it 'puts the n property in the database' do
      expect(entry.n_value).to eq entry.n
    end

    it 'has a correct n property' do
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
        subject(:entry) { FactoryBot.create(:entry, tei: tei) }

        let(:tei_xml) do
          <<-TEI
          <item xml:id="c1d1e444" n="2" corresp="cico:m87">
            <label>2.</label>
            <bibl>
              <author>Agrippae Henrici Corn.</author>,
              <title>De
              incertitude et vanitate scientiarum, declamatio invectiva, ex
              postrema
                <fw type="foot"/>
                <pb type="memofonte"/>
                <fw type="head"/>

                auctoris recognitione</title>,
              <pubPlace>Coloniæ</pubPlace> 
              <date>1584</date>, <extent>in 16</extent>.
            </bibl>

            <note>È trattata la materia estesamente, e quindi la musica,
            l’ottica. l’architettura, la pittura, la scultura sono prese in
            esame: ma quanto al pregio dell’opera ritiensi più rara la
            prima edizione del 1527, e le altre che apparvero fino al 1536
            poiché non erano in quelle stati tolti alcuni passi che
            l’autore (per quietamente vivere) tolse egli stesso dalle
            posteriori edizioni, come può leggersi nella sua
            interessantissima prefazione.</note>
          </item>
          TEI
        end
        let(:tei_document) do
          Nokogiri::XML.parse(tei_xml)
        end
        let(:tei) { tei_document.root }
        let(:entry_book) { FactoryBot.create(:entry_book, entry: entry, book: book) }

        it 'has length 1' do
          expect(entry.corresp.length).to eq 1
        end

        it 'has the right value' do
          expect(entry.corresp[0]).to eq('cico:m87')
        end
      end

      context 'when there are two values in @corresp' do
        subject(:entry) { FactoryBot.create(:entry, tei: tei) }

        let(:tei_xml) do
          <<-TEI
          <item xml:id="c1d1e818" n="15" corresp="cico:88n cico:98g">
            <label>15.</label> 
            <bibl>
              <author>BROTIO Duacensi Nicol.</author>,
              <title> Libellus de utilitate et harmonia artium, Antuerpiæ, apud Simonem
		Cocum,</title>
              <date> A. 1541,</date> 
              <extent>8 fig.</extent>
	            <title>– Addito Libellus Compendiarum virtutis adipiscendæ ec. et carmina.</title>
            </bibl>
	          <note>Le stampe in legno di cui va adorno questo Libretto sono eleganti e singolari. 12 tav. oltre il frontispizio sono quelle del primo lib. e 21 sono quelle del secondo. Magnif. esemp.</note>
          </item>
          TEI
        end
        let(:tei_document) do
          Nokogiri::XML.parse(tei_xml)
        end
        let(:tei) { tei_document.root }

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
        subject(:entry) { FactoryBot.create(:entry, tei: tei) }

        let(:tei_xml) do
          <<-TEI
          <item xml:id="c1d1e444" n="2" corresp="cico:m87">
            <label>2.</label>
            <bibl>
              <author>Agrippae Henrici Corn.</author>,
              <title>De
              incertitude et vanitate scientiarum, declamatio invectiva, ex
              postrema
                <fw type="foot"/>
                <pb type="memofonte"/>
                <fw type="head"/>

                auctoris recognitione</title>,
              <pubPlace>Coloniæ</pubPlace> 
              <date>1584</date>, <extent>in 16</extent>.
            </bibl>

            <note>È trattata la materia estesamente, e quindi la musica,
            l’ottica. l’architettura, la pittura, la scultura sono prese in
            esame: ma quanto al pregio dell’opera ritiensi più rara la
            prima edizione del 1527, e le altre che apparvero fino al 1536
            poiché non erano in quelle stati tolti alcuni passi che
            l’autore (per quietamente vivere) tolse egli stesso dalle
            posteriori edizioni, come può leggersi nella sua
            interessantissima prefazione.</note>
          </item>
          TEI
        end
        let(:tei_document) do
          Nokogiri::XML.parse(tei_xml)
        end
        let(:tei) { tei_document.root }
        let(:version) { FactoryBot.create(:version, contributing_library: contrib, book: book, based_on_original: false) }
        let(:entry_book) { FactoryBot.create(:entry_book, entry: entry, book: book) }

        before do
          entry_book
          version
        end

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
          expect(entry.to_solr['digitized_version_available_facet']).to eq(['Matching copy'])
        end
      end
      context 'when corresp has 2 values' do
        subject(:entry) { FactoryBot.create(:entry, tei: tei) }

        let(:tei_xml) do
          <<-TEI
          <item xml:id="c1d1e818" n="15" corresp="cico:88n cico:98g">
            <label>15.</label> 
            <bibl>
              <author>BROTIO Duacensi Nicol.</author>,
              <title> Libellus de utilitate et harmonia artium, Antuerpiæ, apud Simonem
		Cocum,</title>
              <date> A. 1541,</date> 
              <extent>8 fig.</extent>
	            <title>– Addito Libellus Compendiarum virtutis adipiscendæ ec. et carmina.</title>
            </bibl>
	          <note>Le stampe in legno di cui va adorno questo Libretto sono eleganti e singolari. 12 tav. oltre il frontispizio sono quelle del primo lib. e 21 sono quelle del secondo. Magnif. esemp.</note>
          </item>
          TEI
        end
        let(:tei_document) do
          Nokogiri::XML.parse(tei_xml)
        end
        let(:tei) { tei_document.root }

        it 'dclib_s field has 2 values' do
          expect(entry.to_solr[:dclib_s].length).to eq(2)
        end
      end
    end

    describe 'marc-related fields' do
      context 'when corresp has one value' do
        let(:marc_xml) do
          <<-MARC
          <record>
            <datafield ind1="7" ind2=" " tag="024">
              <subfield code="a">cico:m87</subfield>
              <subfield code="2">dclib</subfield>
            </datafield>
            <datafield ind1="3" ind2="0" tag="246">
              <subfield code="a">De incertitudine et vanitate scientiarum declamatio inuestiua</subfield>
            </datafield>
          </record>
          MARC
        end
        let(:marcxml) { Nokogiri::XML.parse(marc_xml) }
        let(:book) { FactoryBot.create(:book, marcxml: marcxml) }
        let(:entry_book) { FactoryBot.create(:entry_book, entry: entry, book: book) }

        before do
          entry_book
        end

        it 'includes marc fields for indexing' do
          expect(entry.to_solr['title_addl_t']).to include('De incertitudine et vanitate scientiarum declamatio inuestiua')
        end

        it 'excludes marc fields for display' do
          expect(entry.to_solr['title_addl_display']).to be_nil
        end
      end

      context 'when corresp has two values' do
        # subject { described_class.third }
        subject(:entry) { FactoryBot.create(:entry, tei: tei) }

        let(:tei_xml) do
          <<-TEI
          <item xml:id="c1d1e818" n="15" corresp="cico:88n cico:98g">
            <label>15.</label> 
            <bibl>
              <author>BROTIO Duacensi Nicol.</author>,
              <title> Libellus de utilitate et harmonia artium, Antuerpiæ, apud Simonem
		Cocum,</title>
              <date> A. 1541,</date> 
              <extent>8 fig.</extent>
	            <title>– Addito Libellus Compendiarum virtutis adipiscendæ ec. et carmina.</title>
            </bibl>
	          <note>Le stampe in legno di cui va adorno questo Libretto sono eleganti e singolari. 12 tav. oltre il frontispizio sono quelle del primo lib. e 21 sono quelle del secondo. Magnif. esemp.</note>
          </item>
          TEI
        end
        let(:tei_document) do
          Nokogiri::XML.parse(tei_xml)
        end
        let(:tei) { tei_document.root }
        let(:marc_xml_1) do
          <<-MARC
          <record>
            <controlfield tag="008">981020s1541    be a    b     000 0 lat d</controlfield>
            <datafield ind1="7" ind2=" " tag="024">
              <subfield code="a">cico:88n</subfield>
              <subfield code="2">dclib</subfield>
            </datafield>
            <datafield ind1=" " ind2="0" tag="650">
              <subfield code="a">Humanism</subfield>
            </datafield>
         </record>
          MARC
        end
        let(:marcxml_1) { Nokogiri::XML.parse(marc_xml_1) }
        let(:book_1) { FactoryBot.create(:book, marcxml: marcxml_1, digital_cico_number: 'cico:88n') }
        let(:marc_xml_2) do
          <<-MARC
          <record>
           <datafield ind1="7" ind2=" " tag="024">
              <subfield code="a">cico:98g</subfield>
              <subfield code="2">dclib</subfield>
            </datafield>
            <datafield ind1=" " ind2="0" tag="650">
              <subfield code="a">Conduct of life</subfield>
            </datafield>
          </record>
          MARC
        end
        let(:marcxml_2) { Nokogiri::XML.parse(marc_xml_2) }
        let(:book_2) { FactoryBot.create(:book, marcxml: marcxml_2, digital_cico_number: 'cico:98g') }

        let(:entry_book) { FactoryBot.create(:entry_book, entry: entry, book: book_1) }
        let(:entry_book_2) { FactoryBot.create(:entry_book, entry: entry, book: book_2) }

        before do
          EntryBook.all.destroy_all
          Book.find_by(digital_cico_number: 'cico:88n').destroy!
          Book.find_by(digital_cico_number: 'cico:98g').destroy!
          entry_book
          entry_book_2
        end

        it 'keeps only single value for sort fields for entries with multiple marc records' do
          expect(entry.to_solr['pub_date']).to eq(1541)
        end

        it 'merges fields across multiple marc records' do
          expect(entry.to_solr['subject_topic_facet']).to include('Humanism')
          expect(entry.to_solr['subject_topic_facet']).to include('Conduct of life')
        end
      end
    end
  end
end
