class Volume < ApplicationRecord
  belongs_to :book
  has_many :versions

  validates :digital_cico_number, presence: true
end
