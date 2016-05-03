require 'rails_helper'

RSpec.describe 'contributing_libraries/show', type: :view do
  let(:contributing_library) { ContributingLibrary.create!(label: 'Library 1', uri: 'http://example.org/1') }

  before do
    assign(:contributing_library, contributing_library)
  end

  after do
    contributing_library.destroy
  end

  it 'renders attributes in <p>' do
    render
  end
end
