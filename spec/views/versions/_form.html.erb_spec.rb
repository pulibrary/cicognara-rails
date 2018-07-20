require 'rails_helper'

RSpec.describe 'versions/_form', type: :view do
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
      owner_system_number: '1234',
      rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
      iiif_manifest: iiif_manifest
    )
  end

  before do
    volume
    assign(:version, version)
  end

  it 'renders the version form' do
    render(partial: 'versions/form', locals: { iiif_manifests: [iiif_manifest], contributing_libraries: [contributing_library] })

    assert_select 'form[action=?][method=?]', book_volume_version_path(book, volume, version), 'post' do
    end
  end

  context "when the form is being used to create a new Version" do
    let(:new_version) { Version.new }

    before do
      assign(:version, new_version)
      new_version.volume = volume
    end

    it "sets the default field values" do
      render(partial: 'versions/form', locals: { iiif_manifests: [iiif_manifest], contributing_libraries: [contributing_library] })

      expect(rendered).to have_unchecked_field 'version_based_on_original'
    end
  end
end
