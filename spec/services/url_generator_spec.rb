require 'rails_helper'

RSpec.describe UrlGenerator do
  it 'has url options preset' do
    expect(described_class.new.url_options).to eq(host: 'test.org')
  end
end
