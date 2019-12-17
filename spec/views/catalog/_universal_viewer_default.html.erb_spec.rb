require 'rails_helper'

RSpec.describe 'catalog/_universal_viewer_default.html.erb' do
  let(:document) { instance_double(SolrDocument, manifests: manifests) }
  let(:manifests) { [] }
  let(:book) { instance_double(Book, versions: [version], digital_cico_number: 'dcl:xyz') }
  let(:book2) { instance_double(Book, versions: [], digital_cico_number: 'dcl:abc') }
  let(:contributing_library) { instance_double(ContributingLibrary, label: 'Princeton University Library') }
  let(:version) { instance_double(Version, manifest: manifests.first, label: 'Best Copy', contributing_library: contributing_library, based_on_original?: false, id: '12345') }

  context 'when the document has no manifests' do
    before do
      allow(document).to receive(:books).and_return([book])
      allow(version).to receive(:book).and_return(book)
      render partial: 'catalog/universal_viewer_default', locals: { document: document }
    end

    it "doesn't render the viewer" do
      expect(rendered).not_to have_selector '.viewer'
    end
  end

  context 'when a document has a manifest' do
    before do
      allow(document).to receive(:books).and_return([book])
      allow(version).to receive(:book).and_return(book)
      render partial: 'catalog/universal_viewer_default', locals: { document: document }
    end

    let(:manifests) { ['http://test.com/manifest'] }

    it 'renders the viewer' do
      expect(rendered).to have_selector '.viewer'
    end
    it 'renders a tabbed list of all the versions' do
      expect(rendered).to have_selector 'li a[data-manifest-uri="http://test.com/manifest"]'
    end
    it 'displays label text' do
      expect(rendered).to have_content 'Matching Copy (dcl:xyz)'
      expect(rendered).to have_selector 'span', text: 'Princeton University Library'
    end
  end

  context 'when a document has one book with no versions and one book with versions' do
    let(:manifests) { ['http://test.com/manifest'] }

    before do
      allow(document).to receive(:books).and_return([book2, book])
      allow(version).to receive(:book).and_return(book2)
      render partial: 'catalog/universal_viewer_default', locals: { document: document }
    end

    it 'renders the viewer' do
      expect(rendered).to have_selector '.viewer'
    end
    it 'renders a tabbed list of all the versions' do
      expect(rendered).to have_selector 'li a[data-manifest-uri="http://test.com/manifest"]'
    end
    it 'displays label text' do
      expect(rendered).to have_content 'Matching Copy (dcl:xyz)'
      expect(rendered).to have_selector 'span', text: 'Princeton University Library'
    end
  end
end
