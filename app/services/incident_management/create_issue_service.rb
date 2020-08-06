# frozen_string_literal: true

module IncidentManagement
  class CreateIssueService < BaseService
    include Gitlab::Utils::StrongMemoize
    include IncidentManagement::Settings

    def initialize(project, alert)
      super(project, User.alert_bot)
      @alert = alert
    end

    def execute
      return error('setting disabled') unless incident_management_setting.create_issue?
      return error('invalid alert') unless alert.valid?

      result = create_incident
      return error(result.message, result.payload[:issue]) unless result.success?

      result
    end

    private

    attr_reader :alert

    def create_incident
      ::IncidentManagement::Incidents::CreateService.new(
        project,
        current_user,
        title: alert_presenter.full_title,
        description: alert_presenter.issue_description
      ).execute
    end

    def alert_presenter
      strong_memoize(:alert_presenter) do
        alert.present
      end
    end

    def error(message, issue = nil)
      log_error(%{Cannot create incident issue for "#{project.full_name}": #{message}})

      ServiceResponse.error(payload: { issue: issue }, message: message)
    end
  end
end
