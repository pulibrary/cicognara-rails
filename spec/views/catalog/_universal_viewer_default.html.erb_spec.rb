require 'rails_helper'

RSpec.describe 'catalog/_universal_viewer_default.html.erb' do
  let(:document) { instance_double(SolrDocument, manifest_url: 'http://www.test.com', manifests: manifests) }
  let(:manifests) { [] }
  before do
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
  end
end
