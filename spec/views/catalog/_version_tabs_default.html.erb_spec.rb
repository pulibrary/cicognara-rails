require 'rails_helper'

RSpec.describe 'catalog/_version_tabs_default.html.erb' do
  let(:book_record) { Book.new }
  let(:version1) do
    Version.new(
      id: 1,
      book_id: book_record.id,
      manifest: 'manifest1',
      imported_metadata: { 'title_display' => 'First title' }
    )
  end

  let(:version2) do
    Version.new(
      id: 2,
      book_id: book_record.id,
      manifest: 'manifest2',
      imported_metadata: { 'title_display' => 'Title 2' }
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

  context 'The book has no versions' do
    before do
      stub_blacklight_views
      allow(Version).to receive(:where).with(book_id: book_record.id).and_return([])
      allow(Book).to receive(:where).with(digital_cico_number: book_solr_document['id']).and_return([book_record])
    end

    it 'shows a metadata box for the book' do
      assign(:linked_books, [book_solr_document])
      render
      expect(rendered).to match(/book title display/)
      expect(rendered).to have_selector('div#book_digital_cico_number')
    end
  end

  context 'The book has one version' do
    before do
      stub_blacklight_views
      allow(Version).to receive(:where).with(book_id: book_record.id).and_return([version1])
      allow(Book).to receive(:where).with(digital_cico_number: book_solr_document['id']).and_return([book_record])
    end

    it 'shows a metadata box for one version and hides the box for the book' do
      assign(:linked_books, [book_solr_document])
      render
      expect(rendered).to have_selector('div#version_1')
      expect(rendered).to match(/First title/)
      expect(rendered).to have_selector('div#book_digital_cico_number', visible: false)
    end
  end

  context 'The book has two versions' do
    before do
      stub_blacklight_views
      allow(Version).to receive(:where).with(book_id: book_record.id).and_return([version1, version2])
      allow(Book).to receive(:where).with(digital_cico_number: book_solr_document['id']).and_return([book_record])
    end

    it 'shows a metadata box for one version and hides the rest' do
      assign(:linked_books, [book_solr_document])
      render
      expect(rendered).to have_selector('div#version_1')
      expect(rendered).to have_selector('div#version_2', visible: false)
      expect(rendered).to match(/First title/)
      expect(rendered).to have_selector('div#book_digital_cico_number', visible: false)
    end
  end
end
