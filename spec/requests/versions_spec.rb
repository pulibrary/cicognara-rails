require 'rails_helper'

RSpec.describe 'Versions', type: :request do
  # let(:book) { Book.create(digital_cico_number: 'cico:xyz') }
  let(:iiif_manifest) { IIIF::Manifest.create(uri: 'http://example.org/1.json', label: 'Version 1') }
  let(:volume) { Volume.create(digital_cico_number: 'cico:abc') }
  let(:marc_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }
  let(:marcxml) { File.open(marc_path) { |f| Nokogiri::XML(f) } }
  let(:file_uri) { 'file:///test.mrx//marc:record[0]' }
  let(:marc_record) { MarcRecord.create(source: marcxml, file_uri: file_uri) }
  let(:book) { Book.create(marc_record: marc_record, volumes: [volume]) }
  # let(:book) { Book.create(volumes: [volume]) }
  let(:contrib) { ContributingLibrary.create!(label: 'Library 1', uri: 'http://example.org/lib') }
  let(:version) do
    Version.create(
      volume_id: volume.id,
      label: 'Version 1',
      iiif_manifest_id: iiif_manifest.id,
      contributing_library_id: contrib.id,
      owner_system_number: '1234',
      rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
      based_on_original: false
    )
  end

  before { stub_admin_user }

  describe 'GET versions' do
    it 'shows a list of versions' do
      get book_volume_version_path(book, volume, version)
      expect(response).to have_http_status(200)
    end
  end
end
