class Creator < ActiveRecord::Base
  has_and_belongs_to_many :roles, join_table: :creator_roles
  has_and_belongs_to_many :books
end
