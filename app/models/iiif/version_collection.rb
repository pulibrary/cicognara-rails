module IIIF
  class VersionCollection
    attr_reader :version
    delegate :to_json, to: :collection
    def initialize(version)
      @version = version
    end

    def collection
      @collection ||=
        IIIF::Presentation::Collection.new.tap do |c|
          c.label = version.label
          c['@id'] = helper.manifest_version_url(version)
          c.manifests = manifests
        end
    end

    private

    def manifests
      Version.where(owner_system_number: version.owner_system_number).map do |v|
        IIIF::Presentation::Manifest.new.tap do |c|
          c['@id'] = v.manifest
          c['label'] = v.label
        end
      end
    end

    def helper
      @helper ||= UrlGenerator.new
    end
  end
end
