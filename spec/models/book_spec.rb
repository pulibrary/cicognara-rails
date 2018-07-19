require 'rails_helper'

describe Book, type: :model do
  subject(:book) { described_class.create }

  let(:digital_cico_number) { 'xyz' }

  context 'when a volume of the book has been imported' do
    subject(:book) { described_class.create(volumes: [volume]) }

    let(:volume) { Volume.new(digital_cico_number: digital_cico_number) }

    describe '#digital_cico_numbers' do
      it 'accesses digital cico numbers' do
        expect(book.digital_cico_numbers).to eq [volume.digital_cico_number]
      end
    end
  end

  context 'when a creator authorities have been linked' do
    subject(:book) { described_class.create(creators: [creator1, creator2]) }

    let(:role1) { Role.create(label: 'author') }
    let(:role2) { Role.create(label: 'engraver') }

    let(:creator1) { Creator.create(label: 'Alice', roles: [role1]) }
    let(:creator2) { Creator.create(label: 'Bob', roles: [role2]) }

    describe '#creators' do
      it 'accesses the Volume Objects' do
        expect(book.creators.length).to eq(2)
        expect(book.creators.first).to be_a Creator
        expect(book.creators.first.label).to eq 'Alice'
        expect(book.creators.last.label).to eq 'Bob'
      end
    end
  end

  context 'when a subject authority has been linked' do
    subject(:book) { described_class.create(subjects: [subject1, subject2]) }

    let(:subject1) { Subject.create(label: 'puppies') }
    let(:subject2) { Subject.create(label: 'kittens') }

    describe '#subjects' do
      it 'accesses the Subject Objects' do
        expect(book.subjects.length).to eq(2)
        expect(book.subjects.first).to be_a Subject
        expect(book.subjects.first.label).to eq 'puppies'
        expect(book.subjects.last.label).to eq 'kittens'
      end
    end
  end

  describe '#to_solr' do
    subject(:book) { described_class.create(volumes: [volume], marc_record: marc_record) }

    let(:pathtomarc) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }
    let(:marcxml) { File.open(pathtomarc) { |f| Nokogiri::XML(f) } }
    let(:file_uri) { 'file:///test.mrx//marc:record[0]' }
    let(:marc_record) { MarcRecord.create(source: marcxml, file_uri: file_uri) }
    let(:contributing_library) { ContributingLibrary.create! label: 'Example Library', uri: 'http://www.example.org' }
    let(:version) do
      Version.create(
        contributing_library: contributing_library,
        label: 'version 2',
        based_on_original: true,
        owner_system_number: '1234',
        rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
        manifest: 'http://example.org/1.json'
      )
    end
    let(:volume) { Volume.new(digital_cico_number: digital_cico_number, versions: [version]) }
    let(:pathtotei) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml') }

    before do
      volume
      Cicognara::TEIIndexer.new(pathtotei, pathtomarc)
    end

    it 'indexes contributing libraries' do
      expect(book.to_solr['contributing_library_facet']).to eq ['Example Library']
    end

    context 'when a digitized version is available' do
      it 'indexes that fact' do
        expect(book.to_solr['digitized_version_available_facet']).to eq ['Yes']
      end
    end

    context "when a digitized version isn't available" do
      let(:version) do
        Version.create(
          contributing_library: contributing_library,
          label: 'version 2',
          based_on_original: false,
          owner_system_number: '1234',
          rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
          manifest: 'http://example.org/1.json'
        )
      end

      it 'indexes it as false' do
        expect(book.to_solr['digitized_version_available_facet']).to eq ['Yes']
      end

      it 'indexes the manifest' do
        expect(book.to_solr['manifests_s']).to eq ['http://example.org/1.json']
      end
    end
  end
end
