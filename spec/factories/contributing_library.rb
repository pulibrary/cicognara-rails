# frozen_string_literal: true

FactoryBot.define do
  factory :contributing_library do
    label { 'Example Library' }
    uri { 'http://example.org' }
  end
end
