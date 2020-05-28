require 'rails_helper'

RSpec.describe VersionsController do
  describe '#manifest' do
    it 'returns a collection manifest with all versions that have the same owner number' do
      stub_manifest('http://example.org/1.json')
      stub_manifest('http://example.org/2.json')
      contributing_library = ContributingLibrary.create! label: 'Example Library', uri: 'http://www.example.org'
      Book.create(digital_cico_number: 'xyz')
      v1 = Version.create!(
        contributing_library: contributing_library,
        book: Book.first,
        label: 'volume 1',
        based_on_original: false,
        owner_system_number: '1234',
        rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
        manifest: 'http://example.org/1.json'
      )
      v2 = Version.create!(
        contributing_library: contributing_library,
        book: Book.first,
        label: 'volume 2',
        based_on_original: false,
        owner_system_number: '1234',
        rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
        manifest: 'http://example.org/2.json'
      )

      get :manifest, params: { id: v1.id, format: :json }

      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json['manifests'][0]['@id']).to eq v1.manifest
      expect(json['manifests'][1]['@id']).to eq v2.manifest
    end
  end
end
