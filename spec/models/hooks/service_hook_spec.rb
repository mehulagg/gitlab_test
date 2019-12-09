# frozen_string_literal: true

require 'spec_helper'

describe ServiceHook do
  describe 'associations' do
    it { is_expected.to belong_to :service }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:service) }
  end

  describe 'execute' do
    let(:hook) { build(:service_hook) }
    let(:data) { { key: 'value' } }

    it '#execute' do
      expect(WebHookService).to receive(:new).with(hook, data, 'service_hook').and_call_original
      expect_any_instance_of(WebHookService).to receive(:execute)

      hook.execute(data)
    end
  end

  describe '#log_execution' do
    let(:hook) { create(:service_hook) }
    subject { hook.log_execution(trigger: 'push_hooks', headers: {}, request_data: {}, response_status: '200', execution_duration: 1) }

    it 'logs the execution' do
      expect(subject).to be_kind_of(WebHookLog)
    end

    context 'when service hook logging is disabled' do
      before do
        stub_feature_flags(service_hook_logging: false)
      end

      it { is_expected.to be_nil}
    end
  end
end
