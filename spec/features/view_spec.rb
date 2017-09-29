require 'rails_helper'

RSpec.describe 'entry views', type: :feature do
  before(:all) do
    marc = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml')
    MarcIndexer.new.process(marc)

    tei = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml')
    solr = RSolr.connect(url: Blacklight.connection_config[:url])
    solr.add(Cicognara::TEIIndexer.new(tei, marc).solr_docs)
    solr.commit
  end

  after(:all) do
    Book.destroy_all
  end

  it 'displays links to controlled terms' do
    visit '/catalog/15'
    expect(page).to have_link 'Brontius, Nicolaus, 16th century', href: '/catalog?f%5Bname_facet%5D%5B%5D=Brontius%2C+Nicolaus%2C+16th+century'
    expect(page).to have_link 'Humanism—Early works to 1800', href: '/catalog?f%5Bsubject_facet%5D%5B%5D=Humanism%E2%80%94Early+works+to+1800'
  end

  it 'displays metadata' do
    visit '/catalog/15'
    expect(page).to have_selector 'dd.blacklight-dclib_display', text: 'cico:88n'
    expect(page).to have_selector 'dd.blacklight-cico_id_display', text: '15-1'
    expect(page).to have_selector 'dd.blacklight-language_display', text: 'Latin'
    expect(page).to have_selector 'dd.blacklight-description_display', text: '2 v. : ill.'
    expect(page).to have_selector 'dd.blacklight-note_display', text: 'Imprint from colophon.'
    expect(page).to have_selector 'dd.blacklight-published_display', text: 'Antverpiae : Apud Simonem Cocum, Anno 1541.'
    expect(page).to have_selector 'dd.blacklight-title_addl_display', text: 'Libellus de vtilitate et harmonia artium tum futuro iurisconsulto, tum liberalium disciplinarum politiorisue literaturae studiosis utilissimus, Libellus de utilitate et harmonia, and Libellvs de vtilitate et harmonia'
  end

  it 'entries are matched on book name search' do
    visit '/catalog?f%5Bname_facet%5D%5B%5D=Brontius%2C+Nicolaus%2C+16th+century'
    expect(page).to have_link nil, href: '/catalog/15'
  end

  it 'searches by catalogo # without finding dates, etc.' do
    visit '/catalog?search_field=catalogo&q=2'
    expect(page).to have_link 'De incertitude et vanitate scientiarum, declamatio invectiva, ex postrema auctoris recognitione'
    expect(page).not_to have_link 'Addito Libellus Compendiarum virtutis adipiscendæ ec. et carmina.'
  end

  it 'displays marc info once when an entry dclib num matches twice on a single record' do
    visit '/catalog/35'
    expect(page.all('.linked-books').length).to eq 1
  end

  describe 'a logged in user' do
    before do
      @user = stub_admin_user
    end

    it 'displays an admin menu' do
      visit '/'
      expect(page).to have_selector 'a.user-display-name', text: @user.to_s
      expect(page).to have_link 'Books', href: books_path
      expect(page).to have_link 'Contributing Libraries', href: contributing_libraries_path
      expect(page).to have_link 'Users', href: users_path
      expect(page).to have_link 'Log Out', href: main_app.destroy_user_session_path
    end
  end

  describe 'an anonymous user' do
    it 'shows a login link' do
      visit '/'
      expect(page).to have_link 'Log In', href: main_app.new_user_session_path
    end
  end
end
