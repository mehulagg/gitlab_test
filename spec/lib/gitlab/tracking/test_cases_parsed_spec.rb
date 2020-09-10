# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Tracking::TestCasesParsed do
  describe '.track_event' do
    let(:build) { double(project_id: 123) }
    let(:test_suite) { double(name: 'rspec') }
    let(:test_case_1) { double(key: 'test_case_1') }
    let(:test_case_2) { double(key: 'test_case_2') }
    let(:test_case_3) { double(key: 'test_case_3') }

    before do
      stub_const("#{described_class.name}::HLL_BATCH_SIZE", 2)

      allow(test_suite)
        .to receive(:each_test_case)
        .and_yield(test_case_1)
        .and_yield(test_case_2)
        .and_yield(test_case_3)
    end

    it 'tracks the event by batch' do
      hash_1 = Digest::SHA256.hexdigest("#{build.project_id}-#{test_suite.name}-#{test_case_1.key}")
      hash_2 = Digest::SHA256.hexdigest("#{build.project_id}-#{test_suite.name}-#{test_case_2.key}")
      hash_3 = Digest::SHA256.hexdigest("#{build.project_id}-#{test_suite.name}-#{test_case_3.key}")

      expect(Gitlab::UsageDataCounters::HLLRedisCounter)
        .to receive(:track_event).with([hash_1, hash_2], described_class::EVENT_NAME).ordered

      expect(Gitlab::UsageDataCounters::HLLRedisCounter)
        .to receive(:track_event).with([hash_3], described_class::EVENT_NAME).ordered

      described_class.track_event(build, test_suite)
    end
  end
end
