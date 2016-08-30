require 'rails_helper'
require 'json'

RSpec.describe 'xsl', type: :request do
  before(:all) do
    system 'rake tei:partials'
  end
  describe 'section partials' do
    let(:doc) { JSON.parse(response.body)['response']['document'] }
    it 'html page for each partial' do
      get page_path('catalogo/section_2.1')
      expect(response).to have_http_status(200)
    end

    describe 'partials content' do
      before { get page_path('catalogo/section_1.1') }
      it 'includes id attribute for items' do
        expect(response.body).to have_selector('li#item_2')
      end
      it 'incudes id attribute for pages' do
        expect(response.body).to have_selector('span#page_1')
      end
    end
  end
end
