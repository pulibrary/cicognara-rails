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

    def subjects
      subject_headings.concat(spatial)
    end

    def subject_headings
      source.fetch('subject', []).map { |s| s['label'] }.uniq
    end

    def spatial
      source.fetch('spatial', []).map { |s| s['value'] }.uniq
    end

    def languages
      source.fetch('language', []).map { |s| s['value'] }
    end

    def series
      part_of.select { |h| h['@type'] == 'series' }.map { |h| h['label'] }
    end

    def authors
      source.fetch('creator', []).map { |s| s['label'] }
    end

    def publishers
      source.fetch('publisher', []).map { |s| s['value'] }
    end

    def contributors
      source.fetch('contributor', []).map { |s| s['label'] }
    end

    def issued
      source.fetch('issued', []).map { |s| s['value'] }
    end

    def descriptions
      source.fetch('description', []).map { |s| s['value'] }
    end

    def alternatives
      source.fetch('alternative', []).map { |s| s['value'] }
    end

    def editions
      source.fetch('edition', []).map { |s| s['value'] }
    end

    def contents
      source.fetch('tableOfContents', []).map { |s| s['value'] }
    end

    def abstracts
      source.fetch('abstract', []).map { |s| s['value'] }
    end

    def imported_metadata
      {}.merge(
        'author_display' => authors,
        'cico_id_display' => cicognara_number,
        'contents_display' => contents,
        'dclib_display' => dcl_number,
        'description_display' => abstracts,
        'edition_display' => editions,
        'note_display' => descriptions,
        'language_display' => languages,
        'published_display' => publishers,
        'related_name_display' => contributors,
        'subject_t' => subjects,
        'tei_date_display' => issued,
        'tei_title_txt' => title,
        'title_addl_display' => alternatives,
        'title_series_display' => series
      ).compact
    end
  end
end
