# frozen_string_literal: true

require 'spec_helper'

describe IncidentManagement::ProcessPrometheusAlertWorker do
  set(:project) { create(:project) }
  let(:current_time) { Time.now.rfc3339 }
  let(:alert_hash) { { 'startsAt' => current_time } }
  let(:class_instance) { described_class.new }

  describe '#perform' do
    let(:alert_event) { create(:prometheus_alert_event, project: project) }
    let(:create_issue_service) { spy(:create_issue_service) }

    subject { class_instance.perform(alert_event.payload_key, alert_hash) }

    it 'calls create issue service' do
      expect(PrometheusAlertEvent).to receive(:find_by_payload_key).and_call_original

      expect(IncidentManagement::CreateIssueService)
        .to receive(:new).with(project, alert_hash)
        .and_return(create_issue_service)

      expect(create_issue_service).to receive(:execute)

      subject
    end

    context 'with invalid payload key' do
      let(:invalid_payload_key) { 0 }

      subject { class_instance.perform(invalid_payload_key, alert_hash) }

      it 'does not create issues' do
        expect(PrometheusAlertEvent).to receive(:find_by_payload_key).and_call_original
        expect(IncidentManagement::CreateIssueService).not_to receive(:new)

        subject
      end
    end
  end

  describe '#alert_start_time' do
    subject { class_instance.send(:alert_start_time, alert_hash) }
    it 'reads the start time correctly' do
      expect(subject).to eql current_time
    end
  end
end
