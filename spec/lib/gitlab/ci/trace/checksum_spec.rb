# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Trace::Checksum do
  let(:build) { create(:ci_build, :running) }

  subject { described_class.new(build) }

  context 'when build pending state exits' do
    before do
      create(:ci_build_pending_state, build: build, trace_checksum: 'crc32:3564598592')
    end

    context 'when matching persisted trace chunks exist' do
      before do
        create_chunk(index: 0, data: 'a' * 128.kilobytes)
        create_chunk(index: 1, data: 'b' * 128.kilobytes)
        create_chunk(index: 2, data: 'ccccccccccccccccc')
      end

      it 'calculates combined trace chunks CRC32 correctly' do
        expect(subject.chunks_crc32).to eq 3564598592
        expect(subject).to be_valid
      end
    end

    context 'when trace chunks were persisted in a wrong order' do
      before do
        create_chunk(index: 0, data: 'b' * 128.kilobytes)
        create_chunk(index: 1, data: 'a' * 128.kilobytes)
        create_chunk(index: 2, data: 'ccccccccccccccccc')
      end

      it 'makes trace checksum invalid' do
        expect(subject).not_to be_valid
      end
    end

    context 'when one of the trace chunks is missing' do
      before do
        create_chunk(index: 0, data: 'a' * 128.kilobytes)
        create_chunk(index: 2, data: 'ccccccccccccccccc')
      end

      it 'makes trace checksum invalid' do
        expect(subject).not_to be_valid
      end
    end

    context 'when checksums of persisted trace chunks do not match' do
      before do
        create_chunk(index: 0, data: 'a' * 128.kilobytes)
        create_chunk(index: 1, data: 'X' * 128.kilobytes)
        create_chunk(index: 2, data: 'ccccccccccccccccc')
      end

      it 'makes trace checksum invalid' do
        expect(subject).not_to be_valid
      end
    end

    context 'when persisted trace chunks are missing' do
      it 'makes trace checksum invalid' do
        expect(subject.state_crc32).to eq 3564598592
        expect(subject).not_to be_valid
      end
    end
  end

  context 'when build pending state is missing' do
    describe '#state_crc32' do
      it 'returns zero' do
        expect(subject.state_crc32).to be_zero
      end
    end

    describe '#valid?' do
      it { is_expected.not_to be_valid }
    end
  end

  def create_chunk(index:, data:)
    create(:ci_build_trace_chunk, :persisted, build: build,
                                              chunk_index: index,
                                              initial_data: data)
  end
end
