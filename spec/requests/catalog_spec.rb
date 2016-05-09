require 'rails_helper'
require 'json'

RSpec.describe 'CatalogController config', type: :request do
  before(:all) do
    indexer = MarcIndexer.new
    indexer.process(File.join(File.dirname(__FILE__), '..', 'fixtures', 'cicognara.marc.xml'))
    get solr_document_path('cico:m87'), format: :json
  end
  let(:doc) { JSON.parse(response.body)['response']['document'] }
  describe 'document stored fields' do
    it 'stores language_facet for display' do
      expect(doc['language_facet']).to eq(['Latin'])
    end
    it 'stores language_facet for display' do
      expect(doc['published_t']).to eq(['Coloniae : Apud Theodorum Baumium ..., Anno 1584.'])
    end
  end
  describe 'index view' do
    it 'marc records do not appear in search results' do
      get search_catalog_path, format: :json
      docs = JSON.parse(response.body)['response']['docs']
      expect(docs.select { |d| d['id'] == 'cico:m87' }.length).to eq 0
    end
  end
  after(:all) { Book.destroy_all }
end