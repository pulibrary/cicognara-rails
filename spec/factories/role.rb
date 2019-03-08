# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    label { 'author' }
    uri { 'http://id.loc.gov/vocabulary/relators/aut' }
  end
end
