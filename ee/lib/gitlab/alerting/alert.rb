# frozen_string_literal: true

module Gitlab
  module Alerting
    class Alert
      include ActiveModel::Model
      include Gitlab::Utils::StrongMemoize
      include Presentable

      attr_accessor :project, :payload

      SUPPORTED_ALERTING_SERVICES = {
        prometheus: Projects::Prometheus::AlertPresenter
      }.freeze

      def gitlab_alert
        strong_memoize(:gitlab_alert) do
          find_gitlab_alert
        end
      end

      def title
        strong_memoize(:title) do
          gitlab_alert&.title || parsed_payload.title
        end
      end

      def description
        strong_memoize(:description) do
          parsed_payload.description
        end
      end

      def environment
        gitlab_alert&.environment
      end

      def annotations
        strong_memoize(:annotations) do
          parsed_annotations || []
        end
      end

      def starts_at
        strong_memoize(:starts_at) do
          starts_at_to_time
        end
      end

      def full_query
        strong_memoize(:full_query) do
          gitlab_alert&.full_query || expr
        end
      end

      def alert_markdown
        strong_memoize(:alert_markdown) do
          parsed_payload.alert_markdown
        end
      end

      def valid?
        project && title && starts_at
      end

      def present
        super(presenter_class: presenter_class)
      end

      private

      def parsed_payload
        strong_memoize(:parsed_payload) do
          AlertPayloadParser.call(payload)
        end
      end

      def presenter_class
        SUPPORTED_ALERTING_SERVICES.fetch(parsed_payload.service, :unsupported_alerting_service)
      end

      def find_gitlab_alert
        return unless gitlab_alerts_supported?

        metric_id = parsed_payload.metric_id
        return unless metric_id

        Projects::Prometheus::AlertsFinder
          .new(project: project, metric: metric_id)
          .execute
          .first
      end

      def gitlab_alerts_supported?
        parsed_payload.service == :prometheus
      end

      def parsed_annotations
        parsed_payload.annotations&.map do |label, value|
          Alerting::AlertAnnotation.new(label: label, value: value)
        end
      end

      def starts_at_to_time
        value = parsed_payload.starts_at
        return unless value

        Time.rfc3339(value)
      rescue ArgumentError
      end

      # Parses `g0.expr` from `generatorURL`.
      #
      # Example: http://localhost:9090/graph?g0.expr=vector%281%29&g0.tab=1
      def expr
        url = parsed_payload.generator_url
        return unless url

        uri = URI(url)

        Rack::Utils.parse_query(uri.query).fetch('g0.expr')
      rescue URI::InvalidURIError, KeyError
      end
    end
  end
end
