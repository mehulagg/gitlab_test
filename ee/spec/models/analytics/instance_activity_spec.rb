# frozen_string_literal: true

require 'spec_helper'

describe Analytics::InstanceActivity do
  let(:count) { 5 }

  describe '#pipelines_created' do
    let(:counter) { Gitlab::Metrics.pipeline_created_counter }

    it 'returns the number of pipelines created' do
      expect do
        counter.increment({ source: :web }, count)
      end.to change { counter.get({ source: :web }) }.by count
    end
  end

  describe '#releases_created' do
    let(:counter) { Gitlab::Metrics.release_created_counter }

    it 'returns the number of releases created' do
      expect { counter.increment }.to change { counter.get }.by 1
    end
  end
end
