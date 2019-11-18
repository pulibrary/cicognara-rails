require 'rails_helper'

RSpec.describe GettyParser::GettyRecord do
  describe '#imported_metadata' do
    let(:file) { Rails.root.join('spec', 'fixtures', 'resources', filename) }
    let(:record) { described_class.from(JSON.parse(file.read)) }

    context 'with Heidelberg fixture' do
      let(:filename) { 'uh_urnnbndebsz16-diglit-32330.json' }

      it 'maps all the fields' do
        expect(record.imported_metadata).to include(
          'tei_title_txt' => "Iconologia Di Cesare Ripa Pervgino Cav.re De S.ti Mavritio, E Lazzaro: Nella Qvale Si Descrivono Diverse Imagini di Virtù, Vitij, Affetti, Passioni humane, Arti, Discipline, Humori, Elementi, Corpi Celesti, Prouincie d'Italia, Fiumi, Tutte le parti del Mondo, ed altre infinite materie ; Opera Vtile Ad Oratori, Predicatori, Poeti, Pittori, Scvltori, Disegnatori, e ad o",
          'subject_t' => [
            'Cicognara',
            'Parte Seconda',
            'Mitologia, Immagini Sacre, e Costumi Religiosi di diversi Popoli'
          ],
          'cico_id_display' => '4741',
          'dclib_display' => 'srq',
          'language_display' => ['Italian'],
          'title_series_display' => [
            'Quellen zur Geschichte der Kunstgeschichte',
            'Sources for the history of art history',
            'Kunstwissenschaftliche Literatur',
            'Cicognara',
            'Druckschriften',
            "Heidelberger historische Best\u00e4nde \u2014 digital: Quellen zur Geschichte der Kunstgeschichte"
          ]
        )
      end
    end

    context 'with Met fixture' do
      let(:filename) { 'met_00573979.json' }

      it 'maps all the fields' do
        expect(record.imported_metadata).to include(
          'tei_title_txt' => 'Meditations on gout with a consideration of its cure through the use of wine / by George H. Ellwanger ... With a frontispiece & decoration by George Wharton Edwards.',
          'author_display' => ['Ellwanger, George H. (George Herman), 1848-1906.'],
          'subject_t' => [
            'Gout.',
            'RC291 .E44'
          ],
          'language_display' => ['English'],
          'published_display' => ['New York : Dodd, Mead & Company'],
          'related_name_display' => [
            'Edwards, George Wharton, 1859-1950, binding designer.',
            'Dodd, Mead & Company, publisher.'
          ],
          'tei_date_display' => ['[1897]', '1897']
        )
      end
    end

    context 'with Met fixture' do
      let(:filename) { 'gri_9923593930001551.json' }

      it 'maps all the fields' do
        expect(record.imported_metadata).to include(
          'note_display' => [
            'Signatures: A-D4.',
            'Final page blank.',
            '"In certamine literario ciuium Academiae Georgiae Augustae die IV. junii MDCCXCIII praemio a rege M. Britanniae Aug. constituto iudicio ordinis medici ornata."',
            'Includes bibliographical references.'
          ],
          'subject_t' => [
            'Chemistry -- Early works to 1800.',
            'Extracts -- Early works to 1800.',
            "Germany G\u00f6ttingen."
          ]
        )
      end
    end

    context 'with Met fixture' do
      let(:filename) { 'gugg_1710929.json' }

      it 'maps all the fields' do
        expect(record.imported_metadata).to include(
          'tei_title_txt' => 'Claes Oldenburg : an anthology.',
          'title_addl_display' => ['Anthology'],
          'edition_display' => ['2nd ed.'],
          'contents_display' => ['Claes Oldenburg: A Biographical Overview / Marla Prather -- Claes Oldenburg and the Feeling of Things / Germano Celant -- "Unbridled Monuments"; or, How Claes Oldenburg Set Out to Change the World / Mark Rosenthal -- The Sculptor versus the Architect / Germano Celant -- From the Entropic Library / Dieter Koepplin -- Selected Exhibition History, with Large-Scale Projects and Sited Works -- Performance History and Selected Filmography.'],
          'description_display' => ["Claes Oldenburg (b. 1929) first made his mark on the New York art scene in the early 1960s, and from that time he has been widely regarded as one of America's most influential and appealing artists. His subject matter is the everyday object - food, clothing, mechanical devices, and the like - which he reincarnates into witty and provocative sculptures ranging in scale from the intimate to the expansive."]
        )
      end
    end
  end
end
