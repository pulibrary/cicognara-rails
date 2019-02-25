# frozen_string_literal: true

module ManifestStubbing
  def stub_manifest(manifest_url, manifest_file: nil)
    manifest_file ||= manifest_url.gsub(/.*\//, '')
    stub_request(:get, manifest_url).to_return(
      status: 200,
      body: file_fixture("manifests/#{manifest_file}").read,
      headers: { "Content-Type": 'application/json' }
    )
  end

  def stub_resource_sync
    stub_request(:get, 'http://portal.getty.edu/resources/json_data/resourcedump.xml')
      .to_return(
        status: 200,
        body: file_fixture('xml/resourcedump.xml'),
        headers: { "Content-Type": 'application/xml' }
      )
    stub_request(:get, 'http://portal.getty.edu/resources/json_data/testresourcedump_2019-03-04-part1.zip')
      .to_return(
        status: 200,
        body: file_fixture('zips/1.zip'),
        headers: { "Content-Type": 'application/zip' }
      )
    stub_request(:get, 'http://portal.getty.edu/resources/json_data/testresourcedump_2019-03-04-part2.zip')
      .to_return(
        status: 200,
        body: file_fixture('zips/2.zip'),
        headers: { "Content-Type": 'application/zip' }
      )
    stub_request(:get, 'http://portal.getty.edu/resources/json_data/testresourcedump_2019-03-04-part3.zip')
      .to_return(
        status: 200,
        body: file_fixture('zips/3.zip'),
        headers: { "Content-Type": 'application/zip' }
      )
  end
end

RSpec.configure do |config|
  config.include ManifestStubbing
end
