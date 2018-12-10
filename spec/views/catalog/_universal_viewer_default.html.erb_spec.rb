require 'rails_helper'

RSpec.describe 'catalog/_universal_viewer_default.html.erb' do
  let(:document) { instance_double(SolrDocument, manifests: manifests) }
  let(:manifests) { [] }

  before do
    contributing_library = instance_double(ContributingLibrary, label: 'Princeton University Library')
    version = instance_double(Version, manifest: manifests.first, label: 'Best Copy', contributing_library: contributing_library, based_on_original?: false)
    book = instance_double(Book, versions: [version], digital_cico_numbers: ['dcl:xyz'])
    allow(document).to receive(:book).and_return(book)
    allow(version).to receive(:book).and_return(book)
    render partial: 'catalog/universal_viewer_default', locals: { document: document }
  end

  context 'when the document has no manifests' do
    it "doesn't render the viewer" do
      expect(rendered).not_to have_selector '.viewer'
    end
  end
  context 'when a document has manifests' do
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
end
