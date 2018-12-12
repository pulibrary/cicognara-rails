require 'rails_helper'

RSpec.describe 'Versions', type: :request do
  let(:book) { Book.create!(digital_cico_number: 'cico:xyz') }
  let(:contrib) { ContributingLibrary.create!(label: 'Library 1', uri: 'http://example.org/lib') }
  let(:version) do
    Version.create!(book_id: book.id, label: 'Version 1', manifest: 'http://example.org/1.json',
                    contributing_library_id: contrib.id, owner_system_number: '1234',
                    rights: 'http://creativecommons.org/publicdomain/mark/1.0/', based_on_original: false)
  end

  before do
    stub_admin_user
    stub_manifest('http://example.org/1.json')
  end

  after do
    version.destroy
    contrib.destroy
    book.destroy
  end

  describe 'GET versions' do
    it 'shows a list of versions' do
      get book_version_path(book, version)
      expect(response).to have_http_status(200)
    end
  end
end
