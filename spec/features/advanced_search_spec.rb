require 'rails_helper'

RSpec.describe 'searching', type: :feature do
  before do
    stub_manifest('http://example.org/1.json')
    marc = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml')
    tei = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml')
    solr = RSolr.connect(url: Blacklight.connection_config[:url])
    solr.delete_by_query('*:*')
    solr.add(Cicognara::TEIIndexer.new(tei, marc).solr_docs)

    contributing_library = ContributingLibrary.create! label: 'Example Library', uri: 'http://www.example.org'
    Version.create! contributing_library: contributing_library, book: Book.first,
                    label: 'version 2', based_on_original: true, owner_system_number: '1234',
                    rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
                    manifest: 'http://example.org/1.json'
    b = Book.first
    entries = b.entries
    docs = ([b] + entries).map(&:to_solr)
    solr.add(docs)
    solr.commit
  end

  it 'builds the search form to direct clients to the catalog index' do
    visit '/advanced?q=&search_field=all_fields'

    expect(page).to have_selector 'form[action="/catalog"]'
  end

  it 'provides labels to form elements' do
    visit '/advanced?q=&search_field=all_fields'

    expect(page).to have_selector('label', text: 'Options for advanced search')
    expect(page).to have_selector('label', text: 'Advanced search terms')
    expect(page).to have_selector('label', text: 'Options for advanced search - second parameter')
    expect(page).to have_selector('label', text: 'Advanced search terms - second parameter')
    expect(page).to have_selector('label', text: 'Options for advanced search - third parameter')
    expect(page).to have_selector('label', text: 'Advanced search terms - third parameter')
    expect(page).to have_selector('label', text: 'Publication date range (starting year)')
    expect(page).to have_selector('label', text: 'Publication date range (ending year)')
  end

  it 'uses boolean operators to search across fields' do
    visit '/advanced?q=&search_field=all_fields'

    find('#f1').find(:xpath, 'option[3]').select_option
    fill_in('q1', with: 'GHIBERTI')
    choose('op2_NOT')
    fill_in('q2', with: 'Lorenzo')
    find('#advanced-search-submit').click
    expect(page).to have_current_path('/catalog?utf8=%E2%9C%93&q=&search_field=advanced&f1=author&q1=GHIBERTI&op2=NOT&f2=author&q2=Lorenzo&op3=AND&f3=title&q3=&range[pub_date][begin]=&range[pub_date][end]=&sort=cico_sort_s+asc&commit=Search')
  end

  it 'populates advanced search form fields from an existing query' do
    visit '/advanced?q=&search_field=all_fields'

    find('#f1').find(:xpath, 'option[3]').select_option
    fill_in('q1', with: 'GHIBERTI')
    choose('op2_NOT')
    fill_in('q2', with: 'Lorenzo')
    find('#advanced-search-submit').click
    expect(page).to have_current_path('/catalog?utf8=%E2%9C%93&q=&search_field=advanced&f1=author&q1=GHIBERTI&op2=NOT&f2=author&q2=Lorenzo&op3=AND&f3=title&q3=&range[pub_date][begin]=&range[pub_date][end]=&sort=cico_sort_s+asc&commit=Search')

    find('a.advanced_search').click
    expect(page).to have_selector('#q1[value="GHIBERTI"]')
    expect(find_field('op2_NOT')).to be_checked
    expect(page).to have_selector('#q2[value="Lorenzo"]')
  end

  it 'permits users to filter by facets' do
    visit '/catalog?utf8=%E2%9C%93&q=&search_field=all_fields&f1=all_fields&q1=&op2=AND&f2=author&q2=&op3=AND&f3=title&q3=&f_inclusive%5Bname_facet%5D%5B%5D=Agrippa+von+Nettesheim%2C+Heinrich+Cornelius%2C+1486%3F-1535&range%5Bpub_date%5D%5Bbegin%5D=&range%5Bpub_date%5D%5Bend%5D=&sort=cico_sort_s+asc&search_field=advanced&commit=Search'

    expect(page).to have_selector('.filterValue', text: 'Agrippa von Nettesheim, Heinrich Cornelius, 1486?-1535')
  end

  it 'cleans imbalanced " characters in queries' do
    visit '/advanced?q=&search_field=all_fields'

    find('#f1').find(:xpath, 'option[2]').select_option
    fill_in('q1', with: 'GHIBERTI"')
    find('#advanced-search-submit').click
    expect(page).to have_selector('#sortAndPerPage .page_entries', text: '1 entry found')
  end

  it 'combines multiple queries performed on the same field' do
    visit '/advanced?q=&search_field=all_fields'

    find('#f1').find(:xpath, 'option[3]').select_option
    fill_in('q1', with: 'Agrippae')
    fill_in('q2', with: 'Henrici')
    find('#f3').find(:xpath, 'option[3]').select_option
    fill_in('q3', with: 'Corn')

    find('#advanced-search-submit').click
    expect(page).to have_current_path('/catalog?utf8=%E2%9C%93&q=&search_field=advanced&f1=author&q1=Agrippae&op2=AND&f2=author&q2=Henrici&op3=AND&f3=author&q3=Corn&range[pub_date][begin]=&range[pub_date][end]=&sort=cico_sort_s+asc&commit=Search')
  end

  context 'when searching with three queries' do
    before do
      visit '/advanced?q=&search_field=all_fields'
    end

    it 'combines multiple queries with the default AND operator' do
      fill_in('q1', with: 'Agrippae')
      fill_in('q2', with: 'Henrici')
      fill_in('q3', with: 'Corn')

      find('#advanced-search-submit').click
      expect(page).to have_current_path('/catalog?utf8=%E2%9C%93&q=&search_field=advanced&f1=all_fields&q1=Agrippae&op2=AND&f2=author&q2=Henrici&op3=AND&f3=title&q3=Corn&range[pub_date][begin]=&range[pub_date][end]=&sort=cico_sort_s+asc&commit=Search')
    end
  end

  context 'when searching with three queries using the NOT operator' do
    before do
      visit '/advanced?q=&search_field=all_fields'
    end

    it 'combines multiple queries with the NOT operator' do
      fill_in('q1', with: 'Agrippae')
      choose('op2_NOT')
      fill_in('q2', with: 'Henrici')
      choose('op3_NOT')
      fill_in('q3', with: 'Corn')

      find('#advanced-search-submit').click
      expect(page).to have_current_path('/catalog?utf8=%E2%9C%93&q=&search_field=advanced&f1=all_fields&q1=Agrippae&op2=NOT&f2=author&q2=Henrici&op3=NOT&f3=title&q3=Corn&range[pub_date][begin]=&range[pub_date][end]=&sort=cico_sort_s+asc&commit=Search')
    end
  end
end
