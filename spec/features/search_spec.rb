require 'rails_helper'
require 'tei_helper'

RSpec.describe 'searching', type: :feature do
  before(:all) do
    marc = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml')
    MarcIndexer.new.process(marc)

    tei = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml')
    xsl = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'xsl', 'catalogo-item-to-html.xsl')
    solr = RSolr.connect(url: Blacklight.connection_config[:url])
    solr.add(TEIIndexer.new(tei, xsl, marc).solr_docs)
    solr.commit
  end

  after(:all) do
    Book.destroy_all
  end

  it 'displays facets' do
    visit '/catalog?q='
    expect(page.status_code).to eq(200)

    expect(page).to have_selector 'h3.facet-field-heading', text: 'Publication Year'
    expect(page).to have_link '1541'

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
  end

  it 'suggests titles, authors, subjects and institutions, but not other fields' do
    visit '/suggest?q=l'
    terms = JSON.parse(page.body).map { |h| h['term'] }

    expect(terms).not_to include 'latin'
    expect(terms).to include 'learning and scholarship'
  end
end
