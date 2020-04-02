# frozen_string_literal: true

require 'spec_helper'

describe DiffNotePosition, type: :model do
  describe '.create_or_update_by' do
    context 'when a diff note' do
      let(:note) { create(:diff_note_on_merge_request) }
      let(:diff_position) { build(:diff_position) }
      let(:line_code) { 'bd4b7bfff3a247ccf6e3371c41ec018a55230bcc_534_521' }
      let(:diff_note_position) { note.diff_note_positions.first }

      context 'does not have a diff note position' do
        it 'creates a diff note position' do
          note.diff_note_positions.create_or_update_by(:merge_ref_head, line_code: line_code, position: diff_position)

          expect(diff_note_position.position).to eq(diff_position)
          expect(diff_note_position.line_code).to eq(line_code)
          expect(diff_note_position.position_type).to eq('text')
        end
      end

      context 'has a diff note position' do
        it 'updates the existing diff note position' do
          create(:diff_note_position, note: note)
          note.diff_note_positions.create_or_update_by(:merge_ref_head, line_code: line_code, position: diff_position)

          expect(diff_note_position.position).to eq(diff_position)
          expect(diff_note_position.line_code).to eq(line_code)
          expect(note.diff_note_positions.size).to eq(1)
        end
      end
    end
  end
end
