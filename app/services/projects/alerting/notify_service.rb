# frozen_string_literal: true

module Projects
  module Alerting
    class NotifyService < BaseService
      include Gitlab::Utils::StrongMemoize
      include ::IncidentManagement::Settings

      def execute(token)
        return forbidden unless alerts_service_activated?
        return unauthorized unless valid_token?(token)

        alert = process_alert
        return bad_request unless alert.persisted?

        process_incident_issues(alert) if process_issues?
        send_alert_email if send_email?

        ServiceResponse.success
      rescue Gitlab::Alerting::NotificationPayloadParser::BadPayloadError
        bad_request
      end

      private

      delegate :alerts_service, :alerts_service_activated?, to: :project

      def am_alert_params
        strong_memoize(:am_alert_params) do
          Gitlab::AlertManagement::AlertParams.from_generic_alert(project: project, payload: params.to_h)
        end
      end

      def process_alert
        existing_alert = find_alert_by_fingerprint(am_alert_params[:fingerprint])

        if existing_alert
          process_existing_alert(existing_alert)
        else
          create_alert
        end
      end

      def process_existing_alert(alert)
        alert.register_new_event!
      end

      def create_alert
        alert = AlertManagement::Alert.create(am_alert_params)
        alert.execute_services if alert.persisted?
        SystemNoteService.create_new_alert(alert, 'Generic Alert Endpoint')

        alert
      end

      def find_alert_by_fingerprint(fingerprint)
        return unless fingerprint

        AlertManagement::Alert.not_resolved.for_fingerprint(project, fingerprint).first
      end

      def process_incident_issues(alert)
        return if alert.issue

        ::IncidentManagement::ProcessAlertWorker.perform_async(nil, nil, alert.id)
      end

      def send_alert_email
        notification_service
          .async
          .prometheus_alerts_fired(project, [parsed_payload])
      end

      def parsed_payload
        Gitlab::Alerting::NotificationPayloadParser.call(params.to_h, project)
      end

      def valid_token?(token)
        token == alerts_service.token
      end

      def bad_request
        ServiceResponse.error(message: 'Bad Request', http_status: :bad_request)
      end

      def unauthorized
        ServiceResponse.error(message: 'Unauthorized', http_status: :unauthorized)
      end

      def forbidden
        ServiceResponse.error(message: 'Forbidden', http_status: :forbidden)
      end
    end
  end
end
