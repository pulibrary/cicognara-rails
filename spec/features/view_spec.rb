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

  it 'entries are matched on book name search' do
    visit '/catalog?f%5Bname_facet%5D%5B%5D=Brontius%2C+Nicolaus%2C+16th+century'
    expect(page).to have_link nil, href: '/catalog/15'
  end

  it 'searches by catalogo # without finding dates, etc.' do
    visit '/catalog?search_field=catalogo&q=2'
    expect(page).to have_link 'De incertitude et vanitate scientiarum, declamatio invectiva, ex postrema auctoris recognitione'
    expect(page).not_to have_link 'Addito Libellus Compendiarum virtutis adipiscendæ ec. et carmina.'
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
