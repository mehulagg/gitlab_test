# frozen_string_literal: true

module Gitlab
  module Alerting
    class Alert
      include ActiveModel::Model
      include Gitlab::Utils::StrongMemoize
      include Presentable

      attr_accessor :project, :payload

      def gitlab_alert
        strong_memoize(:gitlab_alert) do
          parse_gitlab_alert_from_payload
        end
      end

      def title
        strong_memoize(:title) do
          parse_title_from_payload
        end
      end

      def description
        strong_memoize(:description) do
          parse_description_from_payload
        end
      end

      def environment
        gitlab_alert&.environment
      end

      def annotations
        strong_memoize(:annotations) do
          parse_annotations_from_payload || []
        end
      end

      def valid?
        project && title
      end

      def present
        super(presenter_class: Projects::Prometheus::AlertPresenter)
      end

      private

      def parse_gitlab_alert_from_payload
        metric_id = payload&.dig('labels', 'gitlab_alert_id')
        return unless metric_id

        Projects::Prometheus::AlertsFinder
          .new(project: project, metric: metric_id)
          .execute
          .first
      end

      def parse_title_from_payload
        gitlab_alert&.title ||
          payload&.dig('annotations', 'title') ||
          payload&.dig('annotations', 'summary')
      end

      def parse_description_from_payload
        payload&.dig('annotations', 'description')
      end

      def parse_annotations_from_payload
        payload&.dig('annotations')&.map do |label, value|
          Alerting::AlertAnnotation.new(label: label, value: value)
        end
      end
    end
  end
end
