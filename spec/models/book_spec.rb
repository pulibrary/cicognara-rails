require 'rails_helper'

RSpec.describe Book, type: :model do
  let(:dc_num) { DcNum.new label: 'xyz' }
  let(:book) { described_class.new dc_num: dc_num }
  let(:subject1) { Subject.new label: 'puppies' }
  let(:subject2) { Subject.new label: 'kittens' }
  let(:role1) { Role.new label: 'author' }
  let(:creator1) { Creator.new label: 'Alice' }
  let(:creator_role1) { CreatorRole.new creator: creator1, role: role1 }
  let(:role2) { Role.new label: 'engraver' }
  let(:creator2) { Creator.new label: 'Bob' }
  let(:creator_role2) { CreatorRole.new creator: creator2, role: role2 }

  it 'has a digital cico number' do
    expect(book.dc_num).to eq(dc_num)
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
    expect {
      described_class.create dc_num: dc_num
    }.to raise_error ActiveRecord::RecordInvalid    
  end
end
