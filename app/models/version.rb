class Version < ActiveRecord::Base
  belongs_to :contributing_library
  belongs_to :book
  validates :label, :contributing_library, presence: true
  after_commit :update_index

  def update_index
    docs = ([book.try(:to_solr)] + Array(book.try(:entries)).map(&:to_solr)).compact
    solr.add(docs, params: { softCommit: true })
  end

  private

  def solr
    Blacklight.default_index.connection
  end
end
