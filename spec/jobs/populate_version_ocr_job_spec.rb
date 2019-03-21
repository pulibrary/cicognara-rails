require 'rails_helper'

RSpec.describe PopulateVersionOCRJob do
  let(:contributing_library) do
    ContributingLibrary.create!(
      label: 'Example Library',
      uri: 'https://example.com/library'
    )
  end
  let(:book) { Book.create!(digital_cico_number: '1') }

  context 'when given a version pointing at a manifest with OCR content' do
    it 'indexes it' do
      stub_manifest('http://example.org/1.json')
      version = Version.create!(
        manifest: 'http://example.org/1.json',
        label: 'version',
        contributing_library: contributing_library,
        owner_system_number: 'abc123',
        rights: 'https://creativecommons.org/publicdomain/mark/1.0/',
        based_on_original: false,
        book: book
      )

      described_class.perform_now(version)

      expect(version.ocr_text).to eq %w[Logical Aardvark]
      expect(version.rights).to eq 'http://cicognara.org/microfiche_copyright'
    end
  end
  context 'when a manifest errors' do
    it 'captures it' do
      allow(JSON).to receive(:parse).and_raise 'Broken'
      stub_manifest('http://example.org/1.json')
      version = Version.create!(
        manifest: 'http://example.org/1.json',
        label: 'version',
        contributing_library: contributing_library,
        owner_system_number: 'abc123',
        rights: 'https://creativecommons.org/publicdomain/mark/1.0/',
        based_on_original: false,
        book: book
      )

      expect { described_class.perform_now(version) }.not_to raise_error
    end
  end
end
