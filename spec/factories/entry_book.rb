# frozen_string_literal: true

FactoryBot.define do
  factory :entry_book do
    entry { FactoryBot.create(:entry) }
    book { FactoryBot.create(:book) }
  end
end
