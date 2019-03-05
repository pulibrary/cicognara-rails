class PopulateVersionOCRJob < ApplicationJob
  def perform(version)
    version.ocr_text = extract_ocr_text(version)
    version.save!
  end

  def extract_ocr_text(version)
    manifest_response = Faraday.get(version.manifest)
    json = JSON.parse(manifest_response.body)
    json['structures'].map { |s| s['label'] } if json['structures']
  rescue StandardError
    nil
  end
end
