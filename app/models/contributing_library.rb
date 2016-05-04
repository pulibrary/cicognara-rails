class ContributingLibrary < ActiveRecord::Base
  validates :label, :uri, presence: true
end
