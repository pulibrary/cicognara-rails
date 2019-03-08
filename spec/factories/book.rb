# frozen_string_literal: true

FactoryBot.define do
  factory :book do
    marcxml { Nokogiri::XML::Document.new }
    digital_cico_number { 'xyz' }
  end
end
