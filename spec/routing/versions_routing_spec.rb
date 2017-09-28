require 'rails_helper'

RSpec.describe Version, type: :routing do
  describe 'routing' do
    it 'routes to #new' do
      expect(get: '/books/1/versions/new').to route_to('versions#new', book_id: '1')
    end

    it 'routes to #show' do
      expect(get: '/books/1/versions/2').to route_to('versions#show', id: '2', book_id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/books/1/versions/2/edit').to route_to('versions#edit', id: '2', book_id: '1')
    end

    it 'routes to #create' do
      expect(post: '/books/1/versions').to route_to('versions#create', book_id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: '/books/1/versions/2').to route_to('versions#update', id: '2', book_id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/books/1/versions/2').to route_to('versions#update', id: '2', book_id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/books/1/versions/2').to route_to('versions#destroy', id: '2', book_id: '1')
    end
  end
end
