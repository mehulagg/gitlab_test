# frozen_string_literal: true

module IncidentManagement
  class CancelDeploymentJobsService < BaseService
    include Gitlab::Utils::StrongMemoize

    def initialize(project, params)
      super(project, User.alert_bot, params)
    end

    def execute
      return error_with('invalid alert') unless alert.valid?

      alert.environment.active_deployments.each do |deployment|
        deployment.deployable&.cancel
      end

      success
    end

    private

    def alert
      strong_memoize(:alert) do
        puts "#{self.class.name} - #{__callee__}: params: #{params.inspect}"
        Gitlab::Alerting::Alert.new(project: project, payload: params).present
      end
    end

    def error_with(message)
      log_error(%{Cannot create incident issue for "#{project.full_name}": #{message}})

      error(message)
    end
  end
end
