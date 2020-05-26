class Version < ApplicationRecord
  belongs_to :contributing_library
  belongs_to :book
  validates :label, :contributing_library, :owner_system_number, :rights, presence: true
  validates :manifest, url: true
  validates :based_on_original, inclusion: { in: [true, false] }

  before_save :manifest_metadata
  serialize :ocr_text
  serialize :imported_metadata

  def manifest_metadata
    ManifestMetadata.new.update(self)
  end
end
