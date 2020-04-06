# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::NamespaceSizeChecker do
  let_it_be(:namespace) { create(:namespace) }
  let(:current_size) { 50 }
  let(:limit) { 100 }
  let(:enabled) { true }

  subject do
    described_class.new(
      current_size_proc: -> { current_size },
      limit: limit,
      enabled: enabled,
      namespace: namespace
    )
  end

  describe '#current_size' do
    it 'returns value from proc' do
      expect(subject.current_size).to eq(current_size)
    end
  end

  describe '#enabled?' do
    context 'when enabled' do
      it 'returns true' do
        expect(subject.enabled?).to be_truthy
      end
    end

    context 'when limit is zero' do
      let(:limit) { 0 }

      it 'returns false' do
        expect(subject.enabled?).to be_falsey
      end
    end
  end

  describe '#usage_ratio' do
    context 'when limit is zero' do
      let(:limit) { 0 }

      it 'returns 0' do
        expect(subject.usage_ratio).to eq(0)
      end
    end

    it 'returns correct ratio' do
      expect(subject.usage_ratio).to eq(0.5)
    end
  end
end
