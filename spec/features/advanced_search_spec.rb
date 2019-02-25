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
end
