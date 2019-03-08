# frozen_string_literal: true

FactoryBot.define do
  factory :entry do
    section_head { 'Delle belle arti in generale' }
    section_display { 'Delle belle arti in generale' }
    section_number { '1.1' }
    n_value { '1' }
    entry_id { 'c1d1e413' }
    tei { Nokogiri::XML::Element.new('item', Nokogiri::XML::Document.new) }
  end
end
