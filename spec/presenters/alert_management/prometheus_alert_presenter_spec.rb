# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::PrometheusAlertPresenter do
  let_it_be(:project) { create(:project) }
  let(:payload) do
    {
      'annotations' => {
        'title' => 'Alert title',
        'gitlab_incident_markdown' => '**`markdown example`**',
        'custom annotation' => 'custom annotation value'
      },
      'startsAt' => '2020-04-27T10:10:22.265949279Z',
      'generatorURL' => 'http://8d467bd4607a:9090/graph?g0.expr=vector%281%29&g0.tab=1'
    }
  end

  let!(:alert) do
    create(:alert_management_alert, :prometheus, project: project, payload: payload)
  end

  let(:alert_url) { "http://localhost/#{project.full_path}/-/alert_management/#{alert.iid}/details" }

  subject(:presenter) { described_class.new(alert) }

  describe '#issue_description' do
    let(:markdown_line_break) { '  ' }

    it 'returns an alert issue description' do
      expect(presenter.issue_description).to eq(
        <<~MARKDOWN.chomp
          **Start time:** #{presenter.start_time}#{markdown_line_break}
          **Severity:** #{presenter.severity}#{markdown_line_break}
          **full_query:** `vector(1)`#{markdown_line_break}
          **Monitoring tool:** Prometheus#{markdown_line_break}
          **GitLab alert:** #{alert_url}

          #### Alert Details

          **annotations.custom annotation:** custom annotation value#{markdown_line_break}
          **annotations.gitlab_incident_markdown:** **`markdown example`**#{markdown_line_break}
          **annotations.title:** Alert title#{markdown_line_break}
          **startsAt:** 2020-04-27T10:10:22.265949279Z#{markdown_line_break}
          **generatorURL:** http://8d467bd4607a:9090/graph?g0.expr=vector%281%29&g0.tab=1

          ---

          **`markdown example`**
        MARKDOWN
      )
    end
  end

  describe '#metrics_dashboard_url' do
    subject { presenter.metrics_dashboard_url }

    context 'for a non-prometheus alert' do
      it { is_expected.to be_nil }
    end

    context 'for a self-managed prometheus alert' do
      include_context 'self-managed prometheus alert attributes'

      it { is_expected.to eq(dashboard_url_for_alert) }
    end

    context 'for a gitlab-managed prometheus alert' do
      include_context 'gitlab-managed prometheus alert attributes'

      it { is_expected.to eq(dashboard_url_for_alert) }
    end
  end
end
