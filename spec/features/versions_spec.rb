require 'rails_helper'

RSpec.describe 'version CRUD', type: :feature do
  let(:book) { Book.first_or_create digital_cico_number: 'cico:abc' }
  let(:contrib) { ContributingLibrary.first_or_create label: 'Library 1', uri: 'http://example.org' }

  before do
    stub_admin_user
  end

  after do
    book.destroy
    contrib.destroy
  end

  it 'adds, updates and deletes versions' do
    visit contributing_library_path contrib
    expect(page).to have_content('Library 1')

    visit book_versions_path book
    expect(page).to have_link('Add Version')
    click_on 'Add Version'

    expect(page).to have_content('New Version')
    fill_in 'version_label', with: 'Version 1'
    fill_in 'version_manifest', with: 'http://example.org/1'
    select 'Library 1', from: 'version_contributing_library_id'
    click_on 'Create Version'

    expect(page).to have_content('Version was successfully created.')
    expect(page).to have_content('Version 1')
    expect(page).to have_link('http://example.org/1', href: 'http://example.org/1')

    # update the version
    visit book_versions_path book
    expect(page).to have_link('Edit')
    click_on 'Edit'

    expect(page).to have_content('Editing Version')
    fill_in 'version_label', with: 'Version 1a'
    fill_in 'version_manifest', with: 'http://example.org/1a'
    click_on 'Update Version'

    expect(page).to have_content('Version was successfully updated.')
    expect(page).to have_content('Version 1a')
    expect(page).to have_link('http://example.org/1a', href: 'http://example.org/1a')

    # delete the version
    visit book_versions_path book
    expect(page).to have_link('Destroy')
    click_on 'Destroy'
    expect(page).to have_content('Version was successfully destroyed.')
  end
end
