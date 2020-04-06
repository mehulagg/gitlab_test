# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::NamespaceSizeErrorMessage do
  let_it_be(:namespace) { create(:namespace) }
  let(:current_size) { 50.megabytes }
  let(:checker) do
    Gitlab::NamespaceSizeChecker.new(
      current_size_proc: -> { current_size },
      limit: 100.megabytes,
      namespace: namespace
    )
  end

  subject { described_class.new(checker) }

  describe 'statistics_message' do
    it 'returns the correct message' do
      expect(subject.statistics_message).to eq("You reached 50% of #{namespace.name}'s capacity (50 MB of 100 MB)")
    end

    context 'when usage is below 50%' do
      let(:current_size) { 49.megabytes }

      it 'returns nil' do
        expect(subject.statistics_message).to eq(nil)
      end
    end
  end
end
