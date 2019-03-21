class PopulateVersionOCRJob < ApplicationJob
  def perform(version)
    json = parse_manifest(version)
    version.ocr_text = extract_ocr_text(json)
    version.rights = extract_license(json) if extract_license(json)
    version.save!
  end

  def parse_manifest(version)
    manifest_response = Faraday.get(version.manifest)
    JSON.parse(manifest_response.body)
  rescue StandardError
    {}
  end

  def extract_license(json)
    json['license']
  end

  def extract_ocr_text(json)
    json['structures'].map { |s| s['label'] } if json['structures']
  rescue StandardError
    nil
  end
end
