# frozen_string_literal: true

module ManifestStubbing
  def stub_manifest(manifest_url)
    manifest_file = manifest_url.gsub(/.*\//, '')
    stub_request(:get, manifest_url).to_return(
      status: 200,
      body: file_fixture("manifests/#{manifest_file}").read,
      headers: { "Content-Type": 'application/json' }
    )
  end
end

RSpec.configure do |config|
  config.include ManifestStubbing
end
