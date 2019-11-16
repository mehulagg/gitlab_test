# frozen_string_literal: true

require 'gitlab/metrics/influx_db'
require 'gitlab/metrics/prometheus'

module Gitlab
  module Metrics
    include Gitlab::Metrics::InfluxDb
    include Gitlab::Metrics::Prometheus

    @error = false

    def self.enabled?
      influx_metrics_enabled? || prometheus_metrics_enabled?
    end

    def self.error?
      @error
    end
  end
end
