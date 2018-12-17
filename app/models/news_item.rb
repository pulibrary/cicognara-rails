class NewsItem < ApplicationRecord
  validates :body, presence: true, allow_blank: false
  validates :title, presence: true, allow_blank: false
  belongs_to :user
end
