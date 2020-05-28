class ManifestMetadata
  def update(version)
    json = parse_manifest(version)
    version.label = extract_label(json) if extract_label(json)
    version.ocr_text = extract_ocr_text(json)
    version.rights = extract_license(json) if extract_license(json)
    return unless version.rights == vatican_copyright
    version.based_on_original = true
    version.contributing_library = vatican_library
  end

  def parse_manifest(version)
    Rails.logger.info "Updating metadata from #{version.manifest}"
    manifest_response = Faraday.get(version.manifest)
    JSON.parse(manifest_response.body)
  rescue StandardError
    {}
  end

  def extract_license(json)
    json['license']
  end

  def extract_label(json)
    label = Array.wrap(json['label']).first
    return label if label.is_a?(String)
  end

  def extract_ocr_text(json)
    json['structures'].map { |s| s['label'] } if json['structures']
  end

  def vatican_copyright
    'http://cicognara.org/microfiche_copyright'
  end

  def vatican_library
    ContributingLibrary.find_or_create_by(label: 'Biblioteca Apostolica Vaticana', uri: 'https://www.vaticanlibrary.va')
  end
end
