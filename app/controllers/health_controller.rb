# frozen_string_literal: true

class HealthController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true
  include RequiresWhitelistedMonitoringClient

  CHECKS = [
    Gitlab::HealthChecks::DbCheck,
    Gitlab::HealthChecks::Redis::RedisCheck,
    Gitlab::HealthChecks::Redis::CacheCheck,
    Gitlab::HealthChecks::Redis::QueuesCheck,
    Gitlab::HealthChecks::Redis::SharedStateCheck,
    Gitlab::HealthChecks::GitalyCheck
  ].freeze

  def readiness
    results = Gitlab::HealthChecks::CheckAllService.new.readiness

    render_check_results(results)
  end

  def liveness
    results = Gitlab::HealthChecks::CheckAllService.new.readiness

    render_check_results(results)
  end

  private

  def render_check_results(results)
    success = results.all? { |name, r| r.success }

    response = results.map do |name, r|
      info = { status: r.success ? 'ok' : 'failed' }
      info['message'] = r.message if r.message
      info[:labels] = r.labels if r.labels
      [name, info]
    end
    render json: response.to_h, status: success ? :ok : :service_unavailable
  end
end
