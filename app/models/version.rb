class Version < ActiveRecord::Base
  belongs_to :contributing_library
  belongs_to :volume

  belongs_to :iiif_manifest, class_name: "IIIF::Manifest", foreign_key: "iiif_manifest_id"

  has_one :book, through: :volume
  validates :label, :contributing_library, :owner_system_number, presence: true
  #validates :manifest, :rights, url: true
  validates :rights, url: true
  validates :based_on_original, inclusion: { in: [true, false] }

  after_commit :update_index

  def update_index
    solr.add(solr_docs, params: { softCommit: true })
  end

  private

    def solr_docs
      return [] unless book
      return [book.to_solr] unless book.entry

      ([book.to_solr] + [book.entry.to_solr]).compact
    end

    def solr
      Blacklight.default_index.connection
    end
end
