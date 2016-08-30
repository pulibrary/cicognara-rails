require 'rails_helper'

RSpec.describe 'high_voltage/pages', type: :routing do
  describe 'routing' do
    it 'routes to #show and sets page' do
      expect(get: '/about/index.html').to route_to('high_voltage/pages#show', id: 'about')
    end
    it 'supports nested routes' do
      expect(get: '/catalogo/section_1.5/index.html').to route_to('high_voltage/pages#show', id: 'catalogo/section_1.5')
    end
    it 'index.html must be present' do
      expect(get: '/catalogo/section_1.5').not_to be_routable
    end
  end
end
