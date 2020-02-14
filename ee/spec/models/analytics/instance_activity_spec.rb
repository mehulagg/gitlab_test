# frozen_string_literal: true

require 'spec_helper'

describe Analytics::InstanceActivity do
  describe '#pipelines_created' do
    let(:count) { 5 }
    let(:counter) { Gitlab::Metrics
        .counter(:pipelines_created_total, "Counter of pipelines created") }

    it 'returns the number of pipelines created' do
      expect do
        counter.increment({source: :web}, count)
      end.to change{counter.get({source: :web})}.by count
    end
  end
end
