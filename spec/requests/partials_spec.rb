require 'rails_helper'
require 'json'

RSpec.describe 'xsl', type: :request do
  describe 'section partials' do
    it 'html page for each section partial' do
      get page_path('catalogo/section_2.1')
      expect(response).to have_http_status(200)
    end

    describe 'section links' do
      before { get page_path('catalogo/section_1.2') }
      it 'contain links to other sections' do
        expect(response.body).to have_link('Dell’antichità in genere', href: '/catalogo/section_2.1/index.html')
      end
      it 'does not contain link to current page' do
        expect(response.body).not_to have_link(href: '/catalogo/section_1.2/index.html')
      end
    end

    describe 'partials content' do
      before { get page_path('catalogo/section_1.1') }
      describe 'section structure' do
        it 'includes id attribute for items' do
          expect(response.body).to have_selector('li#item_2')
        end
        it 'incudes id attribute for pages' do
          expect(response.body).to have_selector('span#page_1')
        end
      end
      describe 'item structure' do
        it 'list is wrapped in a ol with class catalogo-list' do
          expect(response.body).to have_selector('ol.catalogo-list')
        end
        it 'item is wrapped in a li with class catalogo-item' do
          expect(response.body).to have_selector('li.catalogo-item')
        end
        it 'item label is wrapped in a span with class catalogo-item-label' do
          expect(response.body).to have_selector('span.catalogo-item-label', text: '15.')
        end
        it 'bibliographic is wrapped in a span with class catalogo-bibl' do
          expect(response.body).to have_selector('span.catalogo-bibl', text: 'Agrippae Henrici Corn.')
        end
        it 'author is wrapped in a span with class catalogo-author' do
          expect(response.body).to have_selector('span.catalogo-author', text: 'Agrippae Henrici Corn.')
        end
        it 'title is wrapped in a span with class catalogo-title' do
          expect(response.body).to have_selector('span.catalogo-title', text: 'Libellus de utilitate')
        end
        it 'extent is wrapped in a span with class catalogo-extent' do
          expect(response.body).to have_selector('span.catalogo-extent', text: '6')
        end
        it 'publication date is wrapped in a span with class catalogo-date' do
          expect(response.body).to have_selector('span.catalogo-date', text: '1811')
        end
        it 'publication info is wrapped in a span with class catalogo-pubPlace' do
          expect(response.body).to have_selector('span.catalogo-pubPlace', text: 'Paris')
        end
        it 'note is wrapped in a div with class catalogo-note' do
          expect(response.body).to have_selector('div.catalogo-note', text: 'Le stampe in legno')
        end
        it 'title is linked to catalog page' do
          expect(response.body).to have_link('Libellus de utilitate', href: '/catalog/15')
        end
      end
    end
  end

  describe 'item partials' do
    it 'html page for each item partial' do
      get page_path('catalogo/_item_15')
      expect(response).to have_http_status(200)
    end
  end
end
