require 'rails_helper'

describe Volume, type: :model do
  it 'requires dcnum to be unique' do
    # book.save
    # create a new book object with the same dcnum as book: xyz
    # expect { described_class.create digital_cico_number: digital_cico_number }.to raise_error ActiveRecord::RecordNotUnique
  end
end
