# frozen_string_literal: true

class DashboardEnvironmentsEnvironmentEntity < EnvironmentEntity
  expose :alert_count do |environment|
    environment.prometheus_alerts.count
  end
  expose :alert_path do |environment|
    metrics_project_environment_path(environment.project, environment)
  end
  expose :last_alert, using: PrometheusAlertEntity, if: -> (*) { last_alert? }

  private

  def last_alert
    object.prometheus_alerts.last
  end

  def last_alert?
    last_alert
  end
end
