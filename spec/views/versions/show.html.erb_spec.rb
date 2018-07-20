require 'rails_helper'

RSpec.describe 'versions/show', type: :view do
  let(:digital_cico_number) { 'xyz' }
  let(:contributing_library) { ContributingLibrary.create(label: 'Example Library', uri: 'http://www.example.org') }
  let(:iiif_manifest) { IIIF::Manifest.create(uri: 'http://example.org/1.json', label: 'Version 1') }

  let(:marc_path) { File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cicognara.marc.xml') }
  let(:marcxml) { File.open(marc_path) { |f| Nokogiri::XML(f) } }
  let(:file_uri) { 'file:///test.mrx//marc:record[0]' }
  let(:marc_record) { MarcRecord.create(source: marcxml, file_uri: file_uri) }
  let(:book) { Book.create(marc_record: marc_record) }

  let(:volume) { Volume.create(digital_cico_number: digital_cico_number, book: book, versions: [version]) }
  let(:version) do
    Version.create(
      contributing_library: contributing_library,
      label: 'version 1',
      based_on_original: true,
      owner_call_number: '2345',
      owner_system_number: '1234',
      other_number: '34567',
      version_edition_statement: 'test',
      version_publication_statement: 'test',
      version_publication_date: '01/01/1970',
      additional_responsibility: 'test',
      provenance: 'test',
      physical_characteristics: 'test',
      rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
      iiif_manifest: iiif_manifest
    )
  end

  before do
    volume
    assign(:version, version)
  end

  it 'renders attributes in <p>' do
    render(template: 'versions/show', locals: { version_iiif_manifest_link: link_to(nil, version.iiif_manifest.uri) })

    expect(rendered).to have_css('td', text: 'Label')
    expect(rendered).to have_css('td', text: version.label)

    expect(rendered).to have_css('td', text: 'Manifest')
    expect(rendered).to have_link(version.iiif_manifest.uri, href: version.iiif_manifest.uri)

    expect(rendered).to have_css('td', text: 'Contributing library')
    expect(rendered).to have_link(contributing_library.label, href: contributing_library_path(contributing_library))

    expect(rendered).to have_css('td', text: 'Owner call number')
    expect(rendered).to have_css('td', text: version.owner_call_number)

    expect(rendered).to have_css('td', text: 'Owner system number')
    expect(rendered).to have_css('td', text: version.owner_system_number)

    expect(rendered).to have_css('td', text: 'Other number')
    expect(rendered).to have_css('td', text: version.other_number)

    expect(rendered).to have_css('td', text: 'Version edition statement')
    expect(rendered).to have_css('td', text: version.version_edition_statement)

    expect(rendered).to have_css('td', text: 'Version publication statement')
    expect(rendered).to have_css('td', text: version.version_publication_statement)

    expect(rendered).to have_css('td', text: 'Version publication date')
    expect(rendered).to have_css('td', text: version.version_publication_date)

    expect(rendered).to have_css('td', text: 'Additional responsibility')
    expect(rendered).to have_css('td', text: version.additional_responsibility)

    expect(rendered).to have_css('td', text: 'Provenance')
    expect(rendered).to have_css('td', text: version.provenance)

    expect(rendered).to have_css('td', text: 'Physical characteristics')
    expect(rendered).to have_css('td', text: version.physical_characteristics)

    expect(rendered).to have_css('td', text: 'Rights')
    expect(rendered).to have_css('td', text: version.rights)

    expect(rendered).to have_css('td', text: 'Based on original')
    expect(rendered).to have_css('input[type="checkbox"][value="1"]')

    expect(rendered).to have_link('Back to Book', href: book_path(volume.book))
    expect(rendered).to have_link('Edit', href: edit_book_volume_version_path(volume.book, volume, version))
    expect(rendered).to have_link('Destroy', href: book_volume_version_path(volume.book, volume, version))
  end
end
