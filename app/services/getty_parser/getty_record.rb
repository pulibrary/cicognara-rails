class GettyParser
  class GettyRecord
    def self.from(json)
      new(source: json)
    end

    attr_reader :source
    def initialize(source:)
      @source = source
    end

    def cicognara?
      part_of.find do |collection|
        collection['@type'] == 'virtualCollection' && collection['label'] == 'Cicognara Collection'
      end.present?
    end

    def contributing_institution
      source['grpContributor'].first['value']
    end

    def manifest_url
      formats.find do |format|
        format['@type'] == 'iiif'
      end.try(:[], 'value')
    end

    def formats
      Array.wrap(source['hasFormat'])
    end

    def part_of
      Array.wrap(source['isPartOf'])
    end

    def cicognara_number
      identifiers.find do |identifier|
        identifier['@type'] == 'cicognaraNumber'
      end.try(:[], 'value')
    end

    def dcl_number
      identifiers.find do |identifier|
        identifier['@type'] == 'dclNumber'
      end.try(:[], 'value')
    end

    def primary_identifier
      identifiers.find do |identifier|
        identifier['@type'] == 'URI'
      end.try(:[], 'value')
    end

    def identifiers
      Array.wrap(source['identifier'])
    end

    def title
      source['title'][0]['value']
    end

    def rights_statement
      source['accessRights'] && source['accessRights']&.first&.dig('value') || default_rights_statement
    end

    def default_rights_statement
      'http://rightsstatements.org/vocab/CNE/1.0/'
    end
  end
end
