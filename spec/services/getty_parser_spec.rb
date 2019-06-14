require 'rails_helper'

RSpec.describe GettyParser do
  before do
    stub_resource_sync
  end
  describe '#urls' do
    it 'returns a set of urls which can grab the latest dump to get' do
      parser = described_class.new

      expect(parser.urls.latest.length).to eq 3
    end
  end

  describe '#records' do
    before do
      FileUtils.rm_f(Rails.root.join('tmp', 'testresourcedump_2019-03-04-part1.zip'))
    end
    it 'downloads zip files from those URLs and parses records out of them' do
      parser = described_class.new

      records = parser.records
      # Only return the 1 cicognara record with a manifest, skip the rest.
      expect(records.length).to eq 1
      record = records.first
      expect(record.primary_identifier).to eq 'http://portal.getty.edu/api/tp3j85'
      expect(record.cicognara?).to eq true
      expect(record.manifest_url).to eq 'https://digi.ub.uni-heidelberg.de/diglit/iiif/ripa1613bd1/manifest.json'
      expect(record.dcl_number).to eq 'srq'
      expect(record.title).to eq "Iconologia Di Cesare Ripa Pervgino Cav.re De S.ti Mavritio, E Lazzaro: Nella Qvale Si Descrivono Diverse Imagini di Virtù, Vitij, Affetti, Passioni humane, Arti, Discipline, Humori, Elementi, Corpi Celesti, Prouincie d'Italia, Fiumi, Tutte le parti del Mondo, ed altre infinite materie ; Opera Vtile Ad Oratori, Predicatori, Poeti, Pittori, Scvltori, Disegnatori, e ad o"
      expect(record.rights_statement).to eq 'https://creativecommons.org/licenses/by-sa/3.0/'
    end
  end

  describe '#import!' do
    it 'imports a version for a matching book with a DCL number' do
      stub_manifest('https://digi.ub.uni-heidelberg.de/diglit/iiif/ripa1613bd1/manifest.json', manifest_file: '4.json')
      book = Book.create!(digital_cico_number: 'dcl:srq')

      described_class.new.import!

      expect(book.reload.versions.length).to eq 1
      version = book.versions.first
      expect(version.contributing_library.label).to eq 'Heidelberg University Library'
    end
  end
end