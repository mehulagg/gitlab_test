# frozen_string_literal: true

class Projects::Environments::PrometheusApiController < Projects::ApplicationController
  include Metrics::Dashboard::PrometheusApiProxy

  before_action :proxyable

  private

  def api_config
    project.prometheus_service.prometheus_api_configs.order(:priority).first
  end

  def proxy_variable_substitution_service
    Prometheus::ProxyVariableSubstitutionService
  end
end
