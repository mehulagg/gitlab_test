# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe Gitlab::SidekiqMiddleware::DuplicateJobs::Strategies::UntilExecuted do
  let(:fake_duplicate_job) do
    instance_double(Gitlab::SidekiqMiddleware::DuplicateJobs::DuplicateJob)
  end

  subject(:strategy) { described_class.new(fake_duplicate_job) }

  describe '#perform' do
    let(:proc) { -> {} }

    it 'deletes the lock after executing' do
      expect(proc).to receive(:call).ordered
      expect(fake_duplicate_job).to receive(:delete!).ordered

      strategy.perform({}) do
        proc.call
      end
    end
  end
end
