# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe Gitlab::SidekiqMiddleware::DuplicateJobs::Strategies::UntilExecuted do
  let(:fake_duplicate_job) do
    instance_double(Gitlab::SidekiqMiddleware::DuplicateJobs::DuplicateJob)
  end

  subject(:strategy) { described_class.new(fake_duplicate_job) }

  describe '#perform' do
    it 'deletes the lock after executing' do
      expect { |b| strategy.perform({}, &b) }.to yield_control
      expect(fake_duplicate_job).to receive(:delete!).ordered
    end
  end
end
