# frozen_string_literal: true

require 'spec_helper'

describe DiffNotePosition, type: :model do
  it 'has a position attribute' do
    diff_position = build(:diff_position)
    line_code = 'bd4b7bfff3a247ccf6e3371c41ec018a55230bcc_534_521'
    diff_note_position = build(:diff_note_position, line_code: line_code, position: diff_position)

    expect(diff_note_position.position).to eq(diff_position)
    expect(diff_note_position.line_code).to eq(line_code)
    expect(diff_note_position.position_type).to eq('text')
  end
end
