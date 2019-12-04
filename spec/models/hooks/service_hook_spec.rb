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
    let(:params) { { something: 'something' } }
    let(:log_message) do
      {
        service_class: 'Service',
        project_id: hook.service.project_id,
        project_path: hook.service.project.full_path,
        message: nil
      }.merge(params)
    end

    specify do
      expect(Gitlab::ProjectServiceLogger).to receive(:info).with(log_message)
      hook.log_execution(params)
    end

    context 'when it logs an error' do
      let(:params) { { error_message: 'Something went wrong', something: 'something' } }
      let(:log_message) do
        {
          service_class: 'Service',
          project_id: hook.service.project_id,
          project_path: hook.service.project.full_path,
          message: 'Something went wrong',
          something: 'something'
        }
      end

      specify do
        expect(Gitlab::ProjectServiceLogger).to receive(:error).with(log_message)
        expect(Gitlab::ProjectServiceLogger).not_to receive(:info)
        hook.log_execution(params)
      end
    end
  end
end
