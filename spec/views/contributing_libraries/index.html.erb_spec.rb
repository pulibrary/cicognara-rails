require 'rails_helper'

RSpec.describe 'contributing_libraries/index', type: :view do
  let(:contributing_library1) { ContributingLibrary.create!(label: 'Libary 1', uri: 'http://example.org/1') }
  let(:contributing_library2) { ContributingLibrary.create!(label: 'Libary 2', uri: 'http://example.org/2') }

  before do
    assign(:contributing_libraries, [contributing_library1, contributing_library2])
  end

  after do
    contributing_library1.destroy
    contributing_library2.destroy
  end

  it 'renders a list of contributing_libraries' do
    render
  end
end
