require 'rails_helper'

RSpec.describe Book, type: :model do
  subject(:book) { described_class.first }

  let(:subject1) { Subject.new label: 'puppies' }
  let(:subject2) { Subject.new label: 'kittens' }
  let(:role1) { Role.new label: 'author' }
  let(:creator1) { Creator.new label: 'Alice' }
  let(:creator_role1) { CreatorRole.new creator: creator1, role: role1 }
  let(:role2) { Role.new label: 'engraver' }
  let(:creator2) { Creator.new label: 'Bob' }
  let(:creator_role2) { CreatorRole.new creator: creator2, role: role2 }
  let(:marc_documents) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }
  let(:tei_documents) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml') }
  let(:solr_client) { Blacklight.default_index.connection }
  let(:tei_indexer) { Cicognara::TEIIndexer.new(tei_documents, marc_documents) }
  let(:solr_documents) { tei_indexer.solr_docs }

  before do
    solr_client.add(solr_documents)
    solr_client.commit
  end

  before do
    stub_manifest('http://example.org/2.json')
    stub_manifest('http://example.org/3.json')
  end

  it 'has a digital cico number' do
    expect(book.digital_cico_numbers).to eq ['cico:m87']
  end

  it 'has multiple subjects' do
    book.subjects = [subject1, subject2]
    expect(book.subjects.first).to eq(subject1)
    expect(book.subjects.last).to eq(subject2)
  end

  it 'has multiple creators with associated roles' do
    book.creator_roles = [creator_role1, creator_role2]
    expect(book.creator_roles.first.creator).to eq(creator1)
    expect(book.creator_roles.first.role).to eq(role1)
    expect(book.creator_roles.last.creator).to eq(creator2)
    expect(book.creator_roles.last.role).to eq(role2)
  end

  describe '#marc_record' do
    let(:file_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }
    let(:marc_record) { MarcRecord.resolve("file://#{file_path}//marc:record[0]") }

    it 'accesses one or many MARC records for a given book' do
      expect(book.marc_record).to be_a MarcRecord
      expect(book.marc_record).to eq marc_record
    end
  end

  describe '#marcxml' do
    let(:file_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }
    let(:marc_record) { MarcRecord.resolve("file://#{file_path}//marc:record[0]") }

    it 'accesses one or many MARC XML elements for a given book' do
      expect(book.marcxml).to be_a Nokogiri::XML::Document
    end
  end

  describe '#to_solr' do
    let(:microfiche_version) do
      Version.create!(contributing_library: contributing_library,
                      book: book,
                      label: 'version 2',
                      based_on_original: true,
                      owner_system_number: '1234',
                      rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
                      manifest: 'http://example.org/2.json')
    end
    let(:matching_version) do
      Version.create!(contributing_library: contributing_library,
                      book: book,
                      label: 'version 3',
                      based_on_original: false,
                      owner_system_number: '1234',
                      rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
                      manifest: 'http://example.org/3.json')
    end
    let(:contributing_library) { ContributingLibrary.create! label: 'Example Library', uri: 'http://www.example.org' }
    it 'indexes contributing libraries' do
      microfiche_version
      book.reload
      solr_document = book.to_solr

      expect(solr_document['contributing_library_facet']).to eq ['Example Library']
    end
    context 'when a microfiche version is available' do
      before do
        microfiche_version
      end
      it 'indexes the manifest and digitized_version=Microfiche' do
        book.reload
        solr_document = book.to_solr

        expect(solr_document['digitized_version_available_facet']).to contain_exactly('Microfiche')
        expect(solr_document['manifests_s']).to eq ['http://example.org/2.json']
        expect(solr_document['text']).to include('Logical', 'Microfiche Header', 'Title Page')
      end
    end
    context 'when a matching version is available' do
      before do
        matching_version
      end
      it 'indexes the manifest and digitized_version=Matching copy' do
        book.reload
        solr_document = book.to_solr

        expect(solr_document['digitized_version_available_facet']).to contain_exactly('Matching copy')
        expect(solr_document['manifests_s']).to eq ['http://example.org/3.json']
        expect(solr_document['text']).to include('Title Page', 'Cap. I')
      end
    end
    context 'when both microfiche and a matching version are available' do
      before do
        microfiche_version
        matching_version
      end
      it 'indexes both manifests and digitized_version=Microfiche & Matching copy' do
        book.reload
        solr_document = book.to_solr

        expect(solr_document['digitized_version_available_facet']).to contain_exactly('Microfiche', 'Matching copy')
        expect(solr_document['manifests_s']).to contain_exactly('http://example.org/2.json', 'http://example.org/3.json')
      end
    end
    context "when a digitized version isn't available" do
      it 'indexes no manifests and digitized_version=None' do
        book.reload
        solr_document = book.to_solr

        expect(solr_document['digitized_version_available_facet']).to eq ['None']
        expect(solr_document['manifests_s']).to eq []
      end
    end
  end
end
