class Version < ApplicationRecord
  belongs_to :contributing_library
  belongs_to :book
  validates :label, :contributing_library, :owner_system_number, presence: true
  validates :manifest, :rights, url: true
  validates :based_on_original, inclusion: { in: [true, false] }

  after_commit :update_index

  def update_index
    docs = ([book.try(:to_solr)] + Array(book.try(:entries)).map(&:to_solr)).compact
    solr.add(docs, params: { softCommit: true })
  end

  def ocr_text
    manifest_response = Faraday.get(manifest)
    json = JSON.parse(manifest_response.body)
    json['structures'].map { |s| s['label'] } if json['structures']
  rescue StandardError
    nil
  end

  private

  def solr
    Blacklight.default_index.connection
  end
end
