# frozen_string_literal: true

require 'spec_helper'

describe IncidentManagement::ProcessPrometheusAlertWorker do
  set(:project) { create(:project) }

  describe '#perform' do
    let(:alert_event) { create(:prometheus_alert_event, project: project) }
    let(:alert_hash) { { alert: 'alert' } }
    let(:create_issue_service) { spy(:create_issue_service) }

    let(:class_instance) { described_class.new }

    subject { class_instance.perform(alert_event.payload_key, alert_hash) }

    it 'calls create issue service' do
      expect(PrometheusAlertEvent).to receive(:find_by_payload_key).and_call_original

      expect(IncidentManagement::CreateIssueService)
        .to receive(:new).with(project, alert_hash)
        .and_return(create_issue_service)

      expect(create_issue_service).to receive(:execute)

      subject
    end

    context 'alert event has related issues' do
      let(:issue) { create(:issue) }
      before do
        alert_event.related_issues << issue
      end

      it 'calls link_issues' do
        expect(class_instance).to receive(:link_issues).with(project, alert_event, alert_hash)
        subject
      end

      it 'creates a system note' do
        expect(SystemNoteService).to receive(:relate_prometheus_alert_issue)

        subject
      end

      context 'issue is closed' do
        let(:issue) { create(:closed_issue) }

        it 'creates and relates a new issue' do
          new_issue = double(:issue)
          expect(class_instance).to receive(:create_issue).with(project, alert_hash) { { issue: new_issue } }
          expect(class_instance).to receive(:relate_issues).with(new_issue, array_including(issue))
          subject
        end
      end

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
end
