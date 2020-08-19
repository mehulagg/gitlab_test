# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Metrics::Dashboard::Stages::TrackPanelType do
  include MetricsDashboardHelpers

  let(:project) { build_stubbed(:project) }
  let(:environment) { build_stubbed(:environment, project: project) }

  describe '#transform!' do
    subject { described_class.new(project, dashboard, environment: environment) }

    let(:dashboard) { load_sample_dashboard.deep_symbolize_keys }

    it 'creates tracking event' do
      stub_application_setting(snowplow_enabled: true, snowplow_collector_hostname: 'fake_snowplow_collector')
      allow(Gitlab::Tracking).to receive(:event).and_call_original

      subject.transform!

      expect(Gitlab::Tracking).to have_received(:event)
        .with('MetricsDashboard::Chart', 'chart_rendered', { label: 'area-chart' })
        .at_least(:once)

      # Snowplow's `SnowplowTracker::AsyncEmitter` will automatically flush, and
      # make a request once its buffer is full. Manually flush it now so that we
      # don't interfere with any other spec that might be using snowplow.
      stub_request(:get, /fake_snowplow_collector/).to_return(status: 200)
      Gitlab::Tracking.send(:snowplow).flush
    end
  end
end
