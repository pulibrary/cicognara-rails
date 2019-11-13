require 'rails_helper'

RSpec.describe 'catalog/_version_tabs_default.html.erb' do
  let(:book_record) { Book.new('id' => 'book_record_digital_cico_number') }
  let(:version1) do
    Version.new(
      id: 1,
      book_id: book_record.id,
      manifest: 'manifest1'
    )
  end

  let(:version2) do
    Version.new(
      id: 2,
      book_id: book_record.id,
      manifest: 'manifest2'
    )
  end

  let(:book_solr_document) do
    SolrDocument.new(
      'id' => 'digital_cico_number',
      'title' => "it's a book",
      'title_display' => 'book title display',
      'format' => 'idk'
    )
  end

  before do
    stub_blacklight_views
    allow(Version).to receive(:where).with(book_id: book_record.id).and_return([version1, version2])
    allow(Book).to receive(:where).with(digital_cico_number: book_solr_document['id']).and_return([book_record])
  end

  it 'shows a metadata box for each version' do
    assign(:linked_books, [book_solr_document])
    render
    expect(rendered).to have_selector 'div#version_1'
    expect(rendered).to have_selector 'div#version_2'
  end
end
