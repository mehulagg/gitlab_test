# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Clusters::Applications::PrometheusHealthCheckWorker, type: :worker do
  let(:app) { create(:clusters_applications_prometheus) }
  let(:app_name) { app.name }
  let(:app_id) { app.id }

  subject { described_class.new.perform(app_name, app_id) }

  RSpec.shared_examples 'no alert' do |parameter|
    it 'does not send alert' do
      expect(dbl).to receive(:foo)

      subject
    end
  end

  context 'when newly unhealthy' do
    it 'sends alert' do
      # expect process alert to be called

      subject
    end
  end

  context 'when newly healthy' do
    before do
      clusters_applications_prometheus.update(healthy: true)
      # stub response from prometheus as unhealthy
    end

    include_examples 'no alert'
  end

  context 'when continuously unhealthy' do
    before do
      clusters_applications_prometheus.update(healthy: false)
      # stub response from prometheus as unhealthy
    end

    include_examples 'no alert'
  end

  context 'when continuously healthy' do
    before do
      clusters_applications_prometheus.update(healthy: true)
      # stub response from prometheus as healthy
    end

    include_examples 'no alert'
  end
end
