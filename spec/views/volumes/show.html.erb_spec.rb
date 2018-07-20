require 'rails_helper'

RSpec.describe 'volumes/show', type: :view do
  let(:digital_cico_number) { 'xyz' }
  let(:contributing_library) { ContributingLibrary.create(label: 'Example Library', uri: 'http://www.example.org') }
  let(:iiif_manifest) { IIIF::Manifest.create(uri: 'http://example.org/1.json', label: 'Version 1') }
  let(:iiif_manifest_2) { IIIF::Manifest.create(uri: 'http://example.org/2.json', label: 'Version 2') }

  let(:marc_path) { File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cicognara.marc.xml') }
  let(:marcxml) { File.open(marc_path) { |f| Nokogiri::XML(f) } }
  let(:file_uri) { 'file:///test.mrx//marc:record[0]' }
  let(:marc_record) { MarcRecord.create(source: marcxml, file_uri: file_uri) }
  let(:book) { Book.create(marc_record: marc_record) }

  let(:volume) { Volume.create(digital_cico_number: digital_cico_number, book: book, versions: [version, version_2]) }
  let(:version) do
    Version.create(
      contributing_library: contributing_library,
      label: 'version 1',
      based_on_original: true,
      owner_system_number: '1234',
      rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
      iiif_manifest: iiif_manifest
    )
  end
  let(:version_2) do
    Version.create(
      contributing_library: contributing_library,
      label: 'version 2',
      based_on_original: true,
      owner_system_number: '2345',
      rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
      iiif_manifest: iiif_manifest_2
    )
  end

  before do
    assign(:volume, volume)
  end

  it 'renders attributes in <p>' do
    render

    expect(rendered).to have_css('td', text: digital_cico_number)
    expect(rendered).to have_link(version.label, href: book_volume_version_path(volume.book, volume, version))
    expect(rendered).to have_css('td', text: contributing_library.label)
    expect(rendered).to have_link('View', href: book_volume_version_path(volume.book, volume, version))
    expect(rendered).to have_link('Edit', href: edit_book_volume_version_path(volume.book, volume, version))
    expect(rendered).to have_link('Destroy', href: book_volume_version_path(volume.book, volume, version))
  end
end
