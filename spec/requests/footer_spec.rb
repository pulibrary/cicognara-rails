require 'rails_helper'

RSpec.describe 'Footer', type: :request do
  it 'shows current year' do
    get '/'
    expect(response.body).to include("#{DateTime.current.year} The Trustees")
  end
end
