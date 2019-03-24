# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolrDocument, type: :model do
  let(:book) { Book.find_or_create_by! digital_cico_number: 'cico:m87' }
  let(:solr_doc) { { 'book_id_s' => [book.id] } }

  it 'looks up books by id' do
    expect(described_class.new(solr_doc).book).to eq(book)
  end
end
