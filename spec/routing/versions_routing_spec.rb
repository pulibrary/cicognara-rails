require 'rails_helper'

RSpec.describe Version, type: :routing do
  describe 'routing' do
    it 'routes to #new' do
      expect(get: '/books/1/volumes/2/versions/new').to route_to('versions#new', book_id: '1', volume_id: '2')
    end

    it 'routes to #show' do
      expect(get: '/books/1/volumes/2/versions/3').to route_to('versions#show', id: '3', book_id: '1', volume_id: '2')
    end

    it 'routes to #edit' do
      expect(get: '/books/1/volumes/2/versions/3/edit').to route_to('versions#edit', id: '3', book_id: '1', volume_id: '2')
    end

    it 'routes to #create' do
      expect(post: '/books/1/volumes/2/versions').to route_to('versions#create', book_id: '1', volume_id: '2')
    end

    it 'routes to #update via PUT' do
      expect(put: '/books/1/volumes/2/versions/3').to route_to('versions#update', id: '3', book_id: '1', volume_id: '2')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/books/1/volumes/2/versions/3').to route_to('versions#update', id: '3', book_id: '1', volume_id: '2')
    end

    it 'routes to #destroy' do
      expect(delete: '/books/1/volumes/2/versions/3').to route_to('versions#destroy', id: '3', book_id: '1', volume_id: '2')
    end
  end
end
