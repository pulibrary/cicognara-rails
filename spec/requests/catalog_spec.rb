require 'rails_helper'
require 'json'

RSpec.describe 'CatalogController config', type: :request do
  before(:all) do
    tei = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.tei.xml')
    marc = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml')
    solr = RSolr.connect(url: Blacklight.connection_config[:url])
    solr.add(Cicognara::TEIIndexer.new(tei, marc).solr_docs)
    solr.commit
  end
  describe 'document stored fields' do
    let(:doc) { JSON.parse(response.body)['response']['document'] }
    before { get solr_document_path('cico:m87'), as: :json }
    it 'stores language_facet for display' do
      expect(doc['language_facet']).to eq(['Latin'])
    end
    it 'stores published_t for display' do
      expect(doc['published_t']).to eq(['Coloniae : Apud Theodorum Baumium ..., Anno 1584.'])
    end
    it 'stores dclib for display' do
      expect(doc['dclib_display']).to eq(['cico:m87'])
    end
    describe 'multiple dclibs in single marc record' do
      it 'multiple dclibs can display for a single marc record' do
        get solr_document_path('cico:gzw'), as: :json
        expect(doc['dclib_display']).to eq(['cico:gzw', 'cico:vzk'])
      end
      it 'document is retrieved on alt_id' do
        get solr_document_path('cico:vzk'), as: :json
        expect(doc['id']).to eq('cico:gzw')
      end
    end
  end
  describe 'index view' do
    it 'marc records do not appear in search results' do
      get search_catalog_path, as: :json
      docs = JSON.parse(response.body)['response']['docs']
      expect(docs.select { |d| d['id'] == 'cico:m87' }.length).to eq 0
    end
  end
  describe 'show view' do
    it 'contains link to catalogo item view' do
      get solr_document_path('15')
      expect(response.body).to have_link('Browse View', href: '/catalogo/section_1.1#item_15')
    end
    it 'displays notes_t 500$3 in bold ' do
      get solr_document_path('4025')
      expect(response.body).to have_xpath('//*[@id="doc_4025"]/div[2]/dl/dd[7]/ul/li[1]/strong')
      expect(response.body).to have_xpath('//*[@id="doc_4025"]/div[2]/dl/dd[7]/ul/li[2]/strong')
    end
    describe 'when solr doc from dc_lib is not found' do
      it 'dclib marc record is not indexed' do
        get solr_document_path('cico:6gq')
        expect(response).to have_http_status(404)
      end
      it 'catalog item refers to missing solr doc' do
        get solr_document_path('66'), as: :json
        dclib = JSON.parse(response.body)['response']['document']['dclib_s']
        expect(dclib).to include('cico:6gq')
      end
      it 'catalog item has alt_id field' do
        get solr_document_path('66'), as: :json
        dclib = JSON.parse(response.body)['response']['document']
        expect(dclib['alt_id']).to include('66')
      end
      it 'catalog item renders without error' do
        get solr_document_path('66')
        expect(response).to have_http_status(200)
      end
    end
  end
end
