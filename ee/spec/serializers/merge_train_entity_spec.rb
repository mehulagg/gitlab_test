# frozen_string_literal: true

require 'spec_helper'

describe MergeTrainEntity do
  let(:merge_train) { create(:merge_train) }
  let(:entity) { described_class.new(merge_train, request: request) }
  let(:request) { double('request') }

  before do
    allow(request).to receive(:current_user).and_return(merge_train.user)
  end

  describe '#as_json' do
    subject { entity.as_json }

    it 'includes attributes' do
      expect(subject[:index]).to eq(merge_train.index)
      expect(subject[:user][:name]).to eq(merge_train.user.name)
      expect(subject[:pipeline][:id]).to eq(merge_train.pipeline.id)
      expect(subject[:created_at]).to eq(merge_train.created_at)
    end
  end
end
