class Version < ActiveRecord::Base
  belongs_to :contributing_library
  belongs_to :book
end
