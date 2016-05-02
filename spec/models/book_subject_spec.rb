require 'rails_helper'

RSpec.describe BookSubject, type: :model do
  let(:book) { Book.new digital_cico_number: 'xyz' }
  let(:subject) { Subject.new label: 'puppies' }
  let(:book_subject) { described_class.new book: book, subject: subject }

  it 'has a book and a subject' do
    expect(book_subject.book).to eq(book)
    expect(book_subject.subject).to eq(subject)
  end
end
