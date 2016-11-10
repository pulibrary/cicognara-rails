require 'rails_helper'

RSpec.describe 'high_voltage/pages', type: :routing do
  describe 'routing' do
    it 'routes to #show and sets page' do
      expect(get: '/about').to route_to('high_voltage/pages#show', id: 'about')
    end
    it 'also supports routes without index.html' do
      expect(get: '/catalogo/section_1.5').to route_to('high_voltage/pages#show', id: 'catalogo/section_1.5')
    end
  end
end
