require 'rails_helper'
require 'json'

RSpec.describe 'Blacklight search fields', type: :request do
  let(:docs) { JSON.parse(response.body)['response']['docs'] }
  it 'section head is searchable in all_fields' do
    get '/catalog.json?search_field=all_fields&q=Delle+belle+arti+in+generale'
    expect(docs.select { |d| d['id'] == '1' }.length).to eq 1
  end
  it 'tei title is searchable in title keyword (also unicode folds)' do
    get '/catalog.json?search_field=title&q=virtutis+adipiscendae'
    expect(docs.select { |d| d['id'] == '15' }.length).to eq 1
  end
  it 'tei author is searchable in author keyword' do
    get '/catalog.json?search_field=author&q=Leon+Battista+Alberti'
    expect(docs.select { |d| d['id'] == '66' }.length).to eq 1
  end
  it 'section head is searchable in subject keyword' do
    get '/catalog.json?search_field=subject&q=Delle+belle+arti+in+generale'
    expect(docs.select { |d| d['id'] == '1' }.length).to eq 1
  end
end