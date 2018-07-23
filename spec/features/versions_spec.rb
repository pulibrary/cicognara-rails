require 'rails_helper'

RSpec.describe 'version CRUD', type: :feature do
  let(:entry) { Entry.create(n_value: '15') }
  let(:marc_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }
  let(:marcxml) { File.open(marc_path) { |f| Nokogiri::XML(f) } }
  let(:file_uri) { 'file:///test.mrx//marc:record[0]' }
  let(:marc_record) { MarcRecord.create(source: marcxml, file_uri: file_uri) }
  let(:volume) { Volume.create(digital_cico_number: 'cico:abc') }
  let(:book) { Book.create(entry: entry, marc_record: marc_record, volumes: [volume]) }

  let(:iiif_manifest) { IIIF::Manifest.create(uri: 'http://example.org/1.json', label: 'Version 1') }
  let(:iiif_manifest_2) { IIIF::Manifest.create(uri: 'http://example.org/2.json', label: 'Version 2') }
  let(:contrib) { ContributingLibrary.create(label: 'Library 1', uri: 'http://example.org/lib') }

  before do
    stub_admin_user

    book
    iiif_manifest
    iiif_manifest_2
    contrib
  end

  it 'adds, updates and deletes versions' do
    visit contributing_library_path contrib
    expect(page).to have_content('Library 1')

    visit book_path book
    expect(page).to have_link('Add Version')
    click_on 'Add Version'

    expect(page).to have_content('New Version')
    fill_in 'version_label', with: 'Version 1'

    select 'http://example.org/1.json', from: 'version_iiif_manifest_id'
    select 'Library 1', from: 'version_contributing_library_id'
    fill_in 'version_rights', with: 'http://creativecommons.org/publicdomain/mark/1.0/'
    fill_in 'version_owner_system_number', with: '1234'
    click_on 'Create Version'

    expect(page).to have_content('Version was successfully created.')
    expect(page).to have_content('Version 1')
    expect(page).to have_link('http://example.org/1.json', href: 'http://example.org/1.json')

    # update the version
    visit book_path book
    expect(page).to have_link('Edit')
    click_on 'Edit'

    expect(page).to have_content('Editing Version')
    fill_in 'version_label', with: 'Version 2'
    select 'http://example.org/2.json', from: 'version_iiif_manifest_id'
    click_on 'Update Version'

    expect(page).to have_content('Version was successfully updated.')
    expect(page).to have_content('Version 2')
    expect(page).to have_link('http://example.org/2.json', href: 'http://example.org/2.json')

    # delete the version
    visit book_path book
    expect(page).to have_link('Destroy')
    click_on 'Destroy'
    expect(page).to have_content('Version was successfully destroyed.')
  end
end
