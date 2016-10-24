class Book < ActiveRecord::Base
  has_many :creator_roles
  has_many :book_subjects
  has_many :subjects, through: :book_subjects
  has_many :entry_books
  has_many :entries, through: :entry_books
  attribute :marcxml, :marc_nokogiri_type

  def to_solr
    Cicognara::BookIndexer.new(self).to_solr.values.first
  end
end
