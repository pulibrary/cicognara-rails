# frozen_string_literal: true

FactoryBot.define do
  factory :version do
    contributing_library { ContributingLibrary.create(label: 'Example Library') }
    book { Book.create(digital_cico_number: 'xyz') }
    owner_call_number {}
    owner_system_number { 'abc123' }
    other_number {}
    label { 'version 2' }
    version_edition_statement {}
    version_publication_statement {}
    version_publication_date {}
    additional_responsibility {}
    provenance {}
    physical_characteristics {}
    rights { 'https://creativecommons.org/publicdomain/mark/1.0/' }
    based_on_original { true }
    manifest { 'http://example.org/1.json' }
    ocr_text { 'Del Sig. Fabio... // Bartholomaei Tortoletti' }
  end
end
