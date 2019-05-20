# frozen_string_literal: true

require 'spec_helper'

describe MergeTrainsSummaryEntity do
  let(:merge_train) { create(:merge_train) }
  let(:entity) { described_class.new(merge_train.merge_request) }

  describe '#as_json' do
    subject { entity.as_json }

    it 'includes attributes' do
      expect(subject[:total_count]).to eq(1)
    end
  end
end
