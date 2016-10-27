# frozen_string_literal: true
class EntryBook < ApplicationRecord
  belongs_to :book
  belongs_to :entry
end
