require 'rails_helper'

RSpec.describe 'catalog/_index_links_default.html.erb' do
  let(:base_doc) { { id: '1', tei_section_number_display: ['1.2'] } }

  before do
    allow_any_instance_of(Blacklight::CatalogHelperBehavior).to receive(:document_counter_with_offset).and_return(4)
    render partial: 'catalog/index_links_default', locals: { document: document, document_counter: 4 }
  end

  context 'when there is no digitized copy' do
    let(:document) { base_doc.merge(digitized_version_available_facet: ['None']).stringify_keys }

    it 'does not have a badge' do
      expect(rendered).not_to have_selector '.digitized-matching'
      expect(rendered).not_to have_selector '.digitized-microfiche'
    end
  end
  context 'when there is a microfiche copy' do
    let(:document) { base_doc.merge(digitized_version_available_facet: ['Microfiche']).stringify_keys }

    it 'has a only Microfiche badge' do
      expect(rendered).to have_selector '.digitized-microfiche', text: 'Microfiche'
      expect(rendered).not_to have_selector '.digitized-matching'
    end
  end
  context 'when there is a matching copy' do
    let(:document) { base_doc.merge(digitized_version_available_facet: ['Matching copy']).stringify_keys }

    it 'has a only Microfiche badge' do
      expect(rendered).to have_selector '.digitized-matching', text: 'Matching copy'
      expect(rendered).not_to have_selector '.digitized-microfiche'
    end
  end
  context 'when there is a matching copy' do
    let(:document) { base_doc.merge(digitized_version_available_facet: ['Microfiche', 'Matching copy']).stringify_keys }

    it 'has both Matching and Microfiche badges' do
      expect(rendered).to have_selector '.digitized-matching', text: 'Matching copy'
      expect(rendered).to have_selector '.digitized-microfiche', text: 'Microfiche'
    end
  end
end
