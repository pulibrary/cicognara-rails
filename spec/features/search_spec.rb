require 'rails_helper'

RSpec.describe 'searching', type: :feature do
  it 'displays facets' do
    visit '/catalog?q='
    expect(page.status_code).to eq(200)

    expect(page).to have_selector 'h3.facet-field-heading', text: 'Publication Year'
    expect(page).to have_link '1541'

    expect(page).to have_selector 'h3.facet-field-heading', text: 'Topic'
    expect(page).to have_link 'Humanism'

    expect(page).to have_selector 'h3.facet-field-heading', text: 'Language'
    expect(page).to have_link 'Latin'

    expect(page).to have_selector 'h3.facet-field-heading', text: 'Era'
    expect(page).to have_link '16th century'

    expect(page).to have_selector 'h3.facet-field-heading', text: 'Genre'
    expect(page).to have_link 'Early works to 1800'

    expect(page).to have_selector 'h3.facet-field-heading', text: 'Name'
    expect(page).to have_link 'Brontius, Nicolaus, 16th century'

    expect(page).to have_selector 'h3.facet-field-heading', text: 'Section'
    expect(page).to have_link 'Delle belle arti in generale'
  end
end
