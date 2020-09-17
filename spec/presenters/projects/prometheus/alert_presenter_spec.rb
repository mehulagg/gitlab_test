# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Prometheus::AlertPresenter do
  include Gitlab::Routing.url_helpers

  let_it_be(:project, reload: true) { create(:project) }

  let(:presenter) { described_class.new(alert) }
  let(:payload) { {} }
  let(:alert) { create(:alerting_alert, project: project, payload: payload) }

  shared_context 'gitlab alert' do
    let(:gitlab_alert) { create(:prometheus_alert, project: project) }
    let(:metric_id) { gitlab_alert.prometheus_metric_id }

    let(:alert) do
      create(:alerting_alert, project: project, metric_id: metric_id, payload: payload)
    end
  end

  describe '#project_full_path' do
    subject { presenter.project_full_path }

    it { is_expected.to eq(project.full_path) }
  end

  describe '#start_time' do
    subject { presenter.start_time }

    let(:starts_at) { '2020-10-31T14:02:04Z' }

    before do
      payload['startsAt'] = starts_at
    end

    context 'with valid utc datetime' do
      it { is_expected.to eq('31 October 2020, 2:02PM (UTC)') }

      context 'with admin time zone not UTC' do
        before do
          allow(Time).to receive(:zone).and_return(ActiveSupport::TimeZone.new('Perth'))
        end

        it { is_expected.to eq('31 October 2020, 2:02PM (UTC)') }
      end
    end

    context 'with invalid datetime' do
      let(:starts_at) { 'invalid' }

      it { is_expected.to be_nil }
    end
  end

  describe '#issue_summary_markdown' do
    let(:markdown_line_break) { '  ' }

    subject { presenter.issue_summary_markdown }

    context 'without default payload' do
      it do
        is_expected.to eq(
          <<~MARKDOWN.chomp
            **Start time:** #{presenter.start_time}

            #### Alert Details

            **startsAt:** #{presenter.starts_at_raw}
          MARKDOWN
        )
      end
    end

    context 'with optional attributes' do
      before do
        payload['annotations'] = {
          'title' => 'Alert Title',
          'foo' => 'value1',
          'bar' => 'value2',
          'description' => 'Alert Description',
          'monitoring_tool' => 'monitoring_tool_name',
          'service' => 'service_name',
          'hosts' => ['http://localhost:3000', 'http://localhost:3001']
        }
        payload['generatorURL'] = 'http://host?g0.expr=query'
      end

      it do
        is_expected.to eq(
          <<~MARKDOWN.chomp
            **Start time:** #{presenter.start_time}#{markdown_line_break}
            **full_query:** `query`#{markdown_line_break}
            **Service:** service_name#{markdown_line_break}
            **Monitoring tool:** monitoring_tool_name#{markdown_line_break}
            **Hosts:** http://localhost:3000 http://localhost:3001

            #### Alert Details

            **annotations.hosts:** ["http://localhost:3000", "http://localhost:3001"]#{markdown_line_break}
            **annotations.service:** service_name#{markdown_line_break}
            **annotations.monitoring_tool:** monitoring_tool_name#{markdown_line_break}
            **annotations.description:** Alert Description#{markdown_line_break}
            **annotations.bar:** value2#{markdown_line_break}
            **annotations.foo:** value1#{markdown_line_break}
            **annotations.title:** Alert Title#{markdown_line_break}
            **generatorURL:** http://host?g0.expr=query#{markdown_line_break}
            **startsAt:** #{presenter.starts_at_raw}
          MARKDOWN
        )
      end
    end

    context 'when hosts is a string' do
      before do
        payload['annotations'] = { 'hosts' => 'http://localhost:3000' }
      end

      it do
        is_expected.to eq(
          <<~MARKDOWN.chomp
          **Start time:** #{presenter.start_time}#{markdown_line_break}
          **Hosts:** http://localhost:3000

          #### Alert Details

          **annotations.hosts:** http://localhost:3000#{markdown_line_break}
          **startsAt:** #{presenter.starts_at_raw}
          MARKDOWN
        )
      end
    end

    context 'with embedded metrics' do
      let(:starts_at) { '2018-03-12T09:06:00Z' }

      shared_examples_for 'markdown with metrics embed' do
        let(:embed_regex) { /\n\[\]\(#{Regexp.quote(presenter.metrics_dashboard_url)}\)\z/ }

        context 'without a starting time available' do
          around do |example|
            Timecop.freeze(starts_at) { example.run }
          end

          before do
            payload.delete('startsAt')
          end

          it { is_expected.to match(embed_regex) }
        end

        context 'with a starting time available' do
          it { is_expected.to match(embed_regex) }
        end
      end

      context 'for gitlab-managed prometheus alerts' do
        include_context 'gitlab-managed prometheus alert attributes'

        let(:alert) do
          create(:alerting_alert, project: project, metric_id: prometheus_metric_id, payload: payload)
        end

        it_behaves_like 'markdown with metrics embed'
      end

      context 'for alerts from a self-managed prometheus' do
        include_context 'self-managed prometheus alert attributes'

        it_behaves_like 'markdown with metrics embed'

        context 'without y_label' do
          let(:y_label) { title }

          before do
            payload['annotations'].delete('gitlab_y_label')
          end

          it_behaves_like 'markdown with metrics embed'
        end

        context 'when not enough information is present for an embed' do
          shared_examples_for 'does not include an embed' do
            it { is_expected.not_to match(/\[\]\(.+\)/) }
          end

          context 'without title' do
            before do
              payload['annotations'].delete('title')
            end

            it_behaves_like 'does not include an embed'
          end

          context 'without environment' do
            before do
              payload['labels'].delete('gitlab_environment_name')
            end

            it_behaves_like 'does not include an embed'
          end

          context 'without full_query' do
            before do
              payload.delete('generatorURL')
            end

            it_behaves_like 'does not include an embed'
          end
        end
      end
    end
  end

  describe '#show_performance_dashboard_link?' do
    subject { presenter.show_performance_dashboard_link? }

    it { is_expected.to be_falsey }

    context 'with gitlab alert' do
      include_context 'gitlab alert'

      it { is_expected.to eq(true) }
    end
  end

  describe '#show_incident_issues_link?' do
    subject { presenter.show_incident_issues_link? }

    it { is_expected.to be_falsey }

    context 'create issue setting enabled' do
      before do
        create(:project_incident_management_setting, project: project, create_issue: true)
      end

      it { is_expected.to eq(true) }
    end
  end

  describe '#details_url' do
    subject { presenter.details_url }

    it { is_expected.to eq(nil) }

    context 'alert management alert present' do
      let_it_be(:am_alert) { create(:alert_management_alert, project: project) }
      let(:alert) { create(:alerting_alert, project: project, payload: payload, am_alert: am_alert) }

      it { is_expected.to eq("http://localhost/#{project.full_path}/-/alert_management/#{am_alert.iid}/details") }
    end
  end

  context 'with gitlab alert' do
    include_context 'gitlab alert'

    describe '#full_title' do
      let(:query_title) do
        "#{gitlab_alert.title} #{gitlab_alert.computed_operator} #{gitlab_alert.threshold} for 5 minutes"
      end

      let(:expected_subject) do
        "#{alert.environment.name}: #{query_title}"
      end

      subject { presenter.full_title }

      it { is_expected.to eq(expected_subject) }
    end

    describe '#metric_query' do
      subject { presenter.metric_query }

      it { is_expected.to eq(gitlab_alert.full_query) }
    end

    describe '#environment_name' do
      subject { presenter.environment_name }

      it { is_expected.to eq(alert.environment.name) }
    end

    describe '#performance_dashboard_link' do
      let(:expected_link) { metrics_project_environment_url(project, alert.environment) }

      subject { presenter.performance_dashboard_link }

      it { is_expected.to eq(expected_link) }
    end

    describe '#incident_issues_link' do
      let(:expected_link) { project_issues_url(project, label_name: described_class::INCIDENT_LABEL_NAME) }

      subject { presenter.incident_issues_link }

      it { is_expected.to eq(expected_link) }
    end
  end

  context 'without gitlab alert' do
    describe '#full_title' do
      subject { presenter.full_title }

      context 'with title' do
        let(:title) { 'some title' }

        before do
          expect(alert).to receive(:title).and_return(title)
        end

        it { is_expected.to eq(title) }
      end

      context 'without title' do
        it { is_expected.to eq('') }
      end
    end

    describe '#metric_query' do
      subject { presenter.metric_query }

      it { is_expected.to be_nil }
    end

    describe '#environment_name' do
      subject { presenter.environment_name }

      it { is_expected.to be_nil }
    end

    describe '#performance_dashboard_link' do
      let(:expected_link) { metrics_project_environments_url(project) }

      subject { presenter.performance_dashboard_link }

      it { is_expected.to eq(expected_link) }
    end
  end

  describe '#metrics_dashboard_url' do
    subject { presenter.metrics_dashboard_url }

    context 'for a non-prometheus alert' do
      it { is_expected.to be_nil }
    end

    context 'for a self-managed prometheus alert' do
      include_context 'self-managed prometheus alert attributes'

      let(:prometheus_payload) { payload }

      it { is_expected.to eq(dashboard_url_for_alert) }
    end

    context 'for a gitlab-managed prometheus alert' do
      include_context 'gitlab-managed prometheus alert attributes'

      let(:prometheus_payload) { payload }

      it { is_expected.to eq(dashboard_url_for_alert) }
    end
  end
end
