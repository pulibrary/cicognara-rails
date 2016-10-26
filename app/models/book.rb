class Book < ActiveRecord::Base
  has_many :creator_roles
  has_many :book_subjects
  has_many :subjects, through: :book_subjects
  has_one :dc_num
  validates :dc_num, uniqueness: true
end
