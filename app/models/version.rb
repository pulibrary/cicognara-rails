class Version < ApplicationRecord
  belongs_to :contributing_library
  belongs_to :book
  validates :label, :contributing_library, :owner_system_number, :rights, presence: true
  validates :manifest, url: true
  validates :based_on_original, inclusion: { in: [true, false] }

  after_commit :update_index
  before_save :manifest_metadata
  serialize :ocr_text
  serialize :imported_metadata

  def update_index
    docs = ([book.try(:to_solr)] + Array(book.try(:entries)).map(&:to_solr)).compact
    solr.add(docs, params: { softCommit: true })
  end

  def manifest_metadata
    ManifestMetadata.new.update(self)
  end

  private

  def solr
    Blacklight.default_index.connection
  end
end
