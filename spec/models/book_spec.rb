require 'rails_helper'

RSpec.describe Book, type: :model do
  let(:digital_cico_number) { 'xyz' }
  let(:book) { described_class.new digital_cico_number: digital_cico_number }
  let(:subject1) { Subject.new label: 'puppies' }
  let(:subject2) { Subject.new label: 'kittens' }
  let(:role1) { Role.new label: 'author' }
  let(:creator1) { Creator.new label: 'Alice' }
  let(:creator_role1) { CreatorRole.new creator: creator1, role: role1 }
  let(:role2) { Role.new label: 'engraver' }
  let(:creator2) { Creator.new label: 'Bob' }
  let(:creator_role2) { CreatorRole.new creator: creator2, role: role2 }

  before do
    stub_manifest('http://example.org/2.json')
    stub_manifest('http://example.org/4.json')
  end

  it 'has a digital cico number' do
    expect(book.digital_cico_number).to eq(digital_cico_number)
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

  it 'requires dcnum to be unique' do
    book.save
    # create a new book object with the same dcnum as book: xyz
    expect { described_class.create digital_cico_number: digital_cico_number }.to raise_error ActiveRecord::RecordNotUnique
  end

  describe '#to_solr' do
    before do
      pathtotei = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml')
      pathtomarc = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml')
      @subject = Cicognara::TEIIndexer.new(pathtotei, pathtomarc)
    end
    let(:microfiche_version) do
      Version.create! contributing_library: vatican_library, book: described_class.first,
                      label: 'version 2', based_on_original: true, owner_system_number: '1234',
                      rights: 'http://cicognara.org/microfiche_copyright',
                      manifest: 'http://example.org/2.json'
    end
    let(:matching_version) do
      Version.create! contributing_library: contributing_library, book: described_class.first,
                      label: 'version 3', based_on_original: false, owner_system_number: '1234',
                      rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
                      manifest: 'http://example.org/4.json'
    end
    let(:contributing_library) { ContributingLibrary.create! label: 'Example Library', uri: 'http://www.example.org' }
    let(:vatican_library) { ContributingLibrary.create! label: 'Biblioteca Apostolica Vaticana', uri: 'http://www.vaticanlibrary.va' }
    it 'indexes contributing libraries' do
      microfiche_version
      b = described_class.first

      expect(b.to_solr['contributing_library_facet']).to eq ['Biblioteca Apostolica Vaticana']
    end
    context 'when a microfiche version is available' do
      before do
        microfiche_version
      end
      it 'indexes the manifest and digitized_version=Microfiche' do
        b = described_class.first
        expect(b.to_solr['digitized_version_available_facet']).to contain_exactly('Microfiche')
        expect(b.to_solr['manifests_s']).to eq ['http://example.org/2.json']
        expect(b.to_solr['text']).to include('Logical', 'Microfiche Header', 'Title Page')
      end
    end
    context 'when a matching version is available' do
      before do
        matching_version
      end
      it 'indexes the manifest and digitized_version=Matching copy' do
        b = described_class.first
        expect(b.to_solr['digitized_version_available_facet']).to contain_exactly('Matching copy')
        expect(b.to_solr['manifests_s']).to eq ['http://example.org/4.json']
        expect(b.to_solr['text']).to include('Logical', 'Aardvark')
      end
    end
    context 'when both microfiche and a matching version are available' do
      before do
        microfiche_version
        matching_version
      end
      it 'indexes both manifests and digitized_version=Microfiche & Matching copy' do
        b = described_class.first
        expect(b.to_solr['digitized_version_available_facet']).to contain_exactly('Microfiche', 'Matching copy')
        expect(b.to_solr['manifests_s']).to contain_exactly('http://example.org/2.json', 'http://example.org/4.json')
      end
    end
    context "when a digitized version isn't available" do
      it 'indexes no manifests and digitized_version=None' do
        b = described_class.first
        expect(b.to_solr['digitized_version_available_facet']).to eq ['None']
        expect(b.to_solr['manifests_s']).to eq []
      end
    end
  end
end
