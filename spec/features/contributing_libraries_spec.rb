require 'rails_helper'

RSpec.describe 'contributing_library CRUD', type: :feature do
  it 'adds, updates and deletes contributing libraries' do
    visit contributing_libraries_path
    expect(page).to have_link('Add Contributing Library')
    click_on 'Add Contributing Library'

    expect(page).to have_content('New Contributing Library')
    fill_in 'contributing_library_label', with: 'Library 1'
    fill_in 'contributing_library_uri', with: 'http://example.org/1'
    click_on 'Create Contributing library'

    expect(page).to have_content('Contributing Library was successfully created.')
    expect(page).to have_content('Library 1')
    expect(page).to have_link('http://example.org/1', href: 'http://example.org/1')

    # update the contributing library
    expect(page).to have_link('Edit')
    click_on 'Edit'

    expect(page).to have_content('Editing Contributing Library')
    fill_in 'contributing_library_label', with: 'Library 2a'
    fill_in 'contributing_library_uri', with: 'http://example.org/2'
    click_on 'Update Contributing library'

    expect(page).to have_content('Contributing Library was successfully updated.')
    expect(page).to have_content('Library 2')
    expect(page).to have_link('http://example.org/2', href: 'http://example.org/2')

    # delete the contributing library
    expect(page).to have_link('Destroy')
    click_on 'Destroy'
    expect(page).to have_content('Contributing Library was successfully destroyed.')
  end
end
