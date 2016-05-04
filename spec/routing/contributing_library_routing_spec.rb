require 'rails_helper'

RSpec.describe ContributingLibrary, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/contributing_libraries').to route_to('contributing_libraries#index')
    end

    it 'routes to #new' do
      expect(get: '/contributing_libraries/new').to route_to('contributing_libraries#new')
    end

    it 'routes to #show' do
      expect(get: '/contributing_libraries/1').to route_to('contributing_libraries#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/contributing_libraries/1/edit').to route_to('contributing_libraries#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/contributing_libraries').to route_to('contributing_libraries#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/contributing_libraries/1').to route_to('contributing_libraries#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/contributing_libraries/1').to route_to('contributing_libraries#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/contributing_libraries/1').to route_to('contributing_libraries#destroy', id: '1')
    end
  end
end
