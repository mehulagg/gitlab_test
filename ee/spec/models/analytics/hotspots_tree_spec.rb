# frozen_string_literal: true

require 'spec_helper'

describe Analytics::HotspotsTree do
  num_edits = 5

  describe '#build' do
    set(:project) { create(:project) }
    subject { described_class.new.build(mapping) }

    let(:directory1) { 'gitlab/ee/app/' }
    let(:file_path1) { directory1 + 'a.rb'}
    let!(:file_path2) { directory1 + 'b.rb' }
    let!(:file_path3) { directory1 + 'c.rb' }
    let!(:file_path4) { directory2 + 'b.rb' }
    let(:directory2) { 'gitlab/ee/spec/' }

    context 'with one file in given timerange' do
      let(:mapping) { { file_path1 => num_edits } }

      it 'returns a hash with one dir and one child within it' do
        expect(subject).to include({
          children: [
            {
              num_edits: num_edits,
              entity: file_path1
            }
          ],
          num_edits: num_edits,
          entity: directory1
        })
      end
    end

    context 'with multiple files' do
      let(:mapping) { { file_path1 => num_edits, file_path2 => num_edits, file_path3 => num_edits } }

      context 'within the same directory' do
        it 'returns a hash with one dir and several children within it' do
          expect(subject).to include({
            children: [
              {
                num_edits: num_edits,
                entity: file_path1
              },
              {
                num_edits: num_edits,
                entity: file_path2
              },
              {
                num_edits: num_edits,
                entity: file_path3
              }
            ],
            num_edits: 3 * num_edits,
            entity: directory1
          })
        end
      end

      context 'within multiple directories' do
        let(:mapping) { { file_path1 => num_edits, file_path2 => num_edits, file_path3 => num_edits, file_path4 => num_edits } }

        it 'returns a hash with multiple directories and children within them' do
          expect(subject).to include({
            children: [
              {
                num_edits: num_edits,
                entity: file_path1
              },
              {
                num_edits: num_edits,
                entity: file_path2
              },
              {
                num_edits: num_edits,
                entity: file_path3
              }
            ],
            num_edits: 3 * num_edits,
            entity: directory1
          },
          {
            children: [
              {
                num_edits: num_edits,
                entity: file_path4
              }
            ],
            num_edits: num_edits,
            entity: directory2
          })
        end
      end
    end
  end
end
