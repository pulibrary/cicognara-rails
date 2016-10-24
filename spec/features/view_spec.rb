require 'rails_helper'

RSpec.describe 'entry views', type: :feature do
  before(:all) do
    marc = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml')
    MarcIndexer.new.process(marc)

    tei = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml')
    xsl = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'xsl', 'catalogo-item-to-html.xsl')
    solr = RSolr.connect(url: Blacklight.connection_config[:url])
    solr.add(TEIIndexer.new(tei, xsl, marc).solr_docs)
    solr.commit
  end

  it 'displays links to controlled terms' do
    visit '/catalog/15'
    expect(page).to have_link 'Brontius, Nicolaus, 16th century', href: '/catalog?f%5Bauthor_display%5D%5B%5D=Brontius%2C+Nicolaus%2C+16th+century'
    expect(page).to have_link 'Humanism—Early works to 1800', href: '/catalog?f%5Bsubject_display%5D%5B%5D=Humanism%E2%80%94Early+works+to+1800'
  end
end
