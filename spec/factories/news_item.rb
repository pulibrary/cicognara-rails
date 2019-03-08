# frozen_string_literal: true

FactoryBot.define do
  factory :news_item do
    title { 'News item title' }
    body { 'News item body' }
    timestamp { DateTime.now.in_time_zone }
    user { User.create }
  end
end
