class Comment < ApplicationRecord
  validates :text, presence: true, allow_blank: false
  belongs_to :user
end
