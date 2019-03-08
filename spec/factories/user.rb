# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { 'alice@example.org' }
    guest { true }
    role { 'user' }

    factory :admin do
      guest { false }
      role { 'admin' }
    end
  end
end
