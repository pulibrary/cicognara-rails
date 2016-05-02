class CreatorRole < ActiveRecord::Base
  belongs_to :book
  belongs_to :creator
  belongs_to :role
end
