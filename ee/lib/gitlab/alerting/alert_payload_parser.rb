# frozen_string_literal: true

module Gitlab
  module Alerting
    class AlertPayloadParser
      def initialize(payload)
        @payload = payload
      end

      def self.call(payload)
        new(payload).call
      end

      def call
        OpenStruct.new(
          service: :prometheus,
          metric_id: metric_id,
          title: title,
          description: description,
          annotations: annotations,
          starts_at: starts_at,
          generator_url: generator_url,
          alert_markdown: alert_markdown
        )
      end

      private

      attr_reader :payload

      def metric_id
        payload&.dig('labels', 'gitlab_alert_id')
      end

      def title
        payload&.dig('annotations', 'title') ||
          payload&.dig('annotations', 'summary') ||
          payload&.dig('labels', 'alertname')
      end

      def description
        payload&.dig('annotations', 'description')
      end

      def annotations
        payload&.dig('annotations')
      end

      def starts_at
        payload&.dig('startsAt')
      end

      def generator_url
        payload&.dig('generatorURL')
      end

      def alert_markdown
        payload&.dig('annotations', 'gitlab_incident_markdown')
      end
    end
  end
end
