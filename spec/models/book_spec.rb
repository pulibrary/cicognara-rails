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
    before(:all) do
      described_class.destroy_all
      Entry.destroy_all
      pathtotei = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml')
      pathtomarc = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml')
      @subject = Cicognara::TEIIndexer.new(pathtotei, pathtomarc)
    end
    let(:version) do
      Version.create! contributing_library: contributing_library, book: described_class.first,
                      label: 'version 2', based_on_original: true
    end
    let(:contributing_library) { ContributingLibrary.create! label: 'Example Library', uri: 'http://www.example.org' }
    it 'indexes contributing libraries' do
      version
      b = described_class.first

      expect(b.to_solr['contributing_library_facet']).to eq ['Example Library']
    end
    context 'when a digitized version is available' do
      it 'indexes that fact' do
        version
        b = described_class.first
        expect(b.to_solr['digitized_version_available_facet']).to eq ['True']
      end
    end
    context "when a digitized version isn't available" do
      let(:version) do
        Version.create! contributing_library: contributing_library, book: described_class.first,
                        label: 'version 2', based_on_original: false
      end
      it 'indexes it as false' do
        version
        b = described_class.first
        expect(b.to_solr['digitized_version_available_facet']).to eq ['False']
      end
    end
  end
end
