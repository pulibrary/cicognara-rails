require 'rails_helper'

RSpec.describe 'version CRUD', type: :feature do
  let(:contrib) { ContributingLibrary.find_or_create_by label: 'Library 1', uri: 'http://example.org' }
  let(:marc_documents) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml') }
  let(:tei_documents) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml') }
  let(:solr_client) { Blacklight.default_index.connection }
  let(:tei_indexer) { Cicognara::TEIIndexer.new(tei_documents, marc_documents, solr_client) }
  let(:solr_documents) { tei_indexer.solr_docs }
  let(:book) { Book.first }

  before do
    solr_client.add(solr_documents)
    solr_client.commit
    stub_admin_user
    stub_manifest('http://example.org/1.json')
    stub_manifest('http://example.org/2.json')
  end

  it 'adds, updates and deletes versions' do
    visit contributing_library_path contrib
    expect(page).to have_content('Library 1')

    visit book_path book
    expect(page).to have_link('Add Version')
    click_on 'Add Version'

    expect(page).to have_content('New Version')
    fill_in 'version_label', with: 'Version 1'
    fill_in 'version_manifest', with: 'http://example.org/1.json'
    select 'Library 1', from: 'version_contributing_library_id'
    fill_in 'version_rights', with: 'http://creativecommons.org/publicdomain/mark/1.0/'
    fill_in 'version_owner_system_number', with: '1234'
    click_on 'Create Version'

    expect(page).to have_content('Version was successfully created.')
    expect(page).to have_content('Version 1')
    expect(page).to have_link('http://example.org/1', href: 'http://example.org/1.json')

    # update the version
    visit book_path book
    expect(page).to have_link('Edit')
    click_on 'Edit'

    expect(page).to have_content('Editing Version')
    fill_in 'version_label', with: 'Version 1a'
    fill_in 'version_manifest', with: 'http://example.org/2.json'
    click_on 'Update Version'

    expect(page).to have_content('Version was successfully updated.')
    expect(page).to have_content('Version 1a')
    expect(page).to have_link('http://example.org/2.json', href: 'http://example.org/2.json')

    # delete the version
    visit book_path book
    expect(page).to have_link('Destroy')
    click_on 'Destroy'
    expect(page).to have_content('Version was successfully destroyed.')
  end
end
