require 'rails_helper'
require 'tei_helper'

RSpec.describe CatalogController, type: :controller do
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

  describe 'GET #show' do
    it 'retrieves linked books' do
      get :show, id: '2'

      linked_books = assigns(:linked_books)
      expect(linked_books.length).to eq 1
      expect(linked_books.first['id']).to eq 'cico:m87'
    end

    it 'does not error when there are no linked books' do
      get :show, id: 'cico:m87'
      expect(assigns(:linked_books)).to eq []
    end

    it 'book has configured display fields from marc' do
      get :show, id: '2'

      linked_books = assigns(:linked_books)
      expect(linked_books.first['title_addl_display']).to include('De incertitudine et vanitate scientiarum declamatio inuestiua')
    end
  end
end
