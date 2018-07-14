class Volume < ApplicationRecord
  belongs_to :book
  has_many :versions
  belongs_to :iiif_record

  validates :digital_cico_number, presence: true
end
