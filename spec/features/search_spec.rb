require 'rails_helper'

RSpec.describe 'searching', type: :feature do
  before(:all) do
    stub_manifest('http://example.org/4.json')
    marc = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml')
    tei = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml')
    solr = RSolr.connect(url: Blacklight.connection_config[:url])
    solr.delete_by_query('*:*')
    solr.add(Cicognara::TEIIndexer.new(tei, marc).solr_docs)

    contributing_library = ContributingLibrary.create! label: 'Example Library', uri: 'http://www.example.org'
    Version.create! contributing_library: contributing_library, book: Book.first,
                    label: 'version 2', based_on_original: true, owner_system_number: '1234',
                    rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
                    manifest: 'http://example.org/4.json'
    b = Book.first
    entries = b.entries
    docs = ([b] + entries).map(&:to_solr)
    solr.add(docs)
    solr.commit
  end

  it 'displays facets' do
    visit '/catalog?q='
    expect(page.status_code).to eq(200)

    expect(page).to have_selector 'h3.facet-field-heading', text: 'Publication Year'
    expect(page).to have_css '#range_pub_date_begin'
    expect(page).to have_css '#range_pub_date_end'

    expect(page).to have_selector 'h3.facet-field-heading', text: 'Topic'
    expect(page).to have_link 'Humanism'

    expect(page).to have_selector 'h3.facet-field-heading', text: 'Language'
    expect(page).to have_link 'Latin'

    expect(page).to have_selector 'h3.facet-field-heading', text: 'Era'
    expect(page).to have_link '16th century'

    expect(page).to have_selector 'h3.facet-field-heading', text: 'Genre'
    expect(page).to have_link 'Early works to 1800'

    expect(page).to have_selector 'h3.facet-field-heading', text: 'Name'
    expect(page).to have_link 'Brontius, Nicolaus, 16th century'

    expect(page).to have_selector 'h3.facet-field-heading', text: 'Section'
    expect(page).to have_link 'Delle belle arti in generale'

    expect(page).to have_selector 'h3.facet-field-heading', text: 'Contributing Library'
    expect(page).to have_link 'Example Library'

    expect(page).to have_selector 'h3.facet-field-heading', text: 'Digitized Version Available'
    expect(page).to have_link 'Microfiche'
  end

  it 'retrieves items by manifest range labels' do
    stub_request(:get, 'http://example.org/4.json').with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Ruby'
      }
    ).to_return(status: 200, body: '', headers: {})
    visit '/catalog?q=aardvark'
    expect(page).to have_selector 'span.catalogo-author', text: 'Agrippae Henrici Corn.'
    expect(page).to have_selector 'span.catalogo-title', text: 'De incertitude et vanitate scientiarum, declamatio invectiva, ex postrema'
  end

  it 'suggests titles, authors, subjects and institutions, but not other fields' do
    visit '/suggest?q=l'
    terms = JSON.parse(page.body).map { |h| h['term'] }

    expect(terms).not_to include 'latin'
    expect(terms).to include 'learning and scholarship'
  end
end
