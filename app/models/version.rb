class Version < ApplicationRecord
  belongs_to :contributing_library
  belongs_to :book
  validates :label, :contributing_library, :owner_system_number, presence: true
  validates :manifest, :rights, url: true
  validates :based_on_original, inclusion: { in: [true, false] }

  after_commit :update_index
  after_commit :populate_ocr_text, if: :saved_change_to_manifest?, on: [:create, :update]
  serialize :ocr_text

  def update_index
    docs = ([book.try(:to_solr)] + Array(book.try(:entries)).map(&:to_solr)).compact
    solr.add(docs, params: { softCommit: true })
  end

  def populate_ocr_text
    PopulateVersionOCRJob.perform_later(self)
  end

  private

  def solr
    Blacklight.default_index.connection
  end
end
