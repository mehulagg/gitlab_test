# frozen_string_literal: true


module Gitlab
  module AlertManagement
    module Payload
      class Base
        include ActiveModel::Model
        include Gitlab::Utils::StrongMemoize

        attr_accessor :project, :payload

        def self.add_attribute(key, paths:, type: nil, fallback: Proc.new { nil })
          send(:define_method, key) do
            strong_memoize(key) do
              target_path = paths.find { |path| payload&.dig(*path) }
              return fallback.call unless target_path

              value = payload&.dig(*target_path)
              value = case type
                      when :rfc3339
                        parse_rfc3339(value)
                      when :time
                        parse_time(value)
                      when :integer
                        value.to_i
                      else
                        value
                      end

              value.presence || fallback.call
            end
          end
        end

        add_attribute :something, paths: [['title']]

        def alert_markdown; end
        def alert_title; end
        def annotations; end
        def ends_at; end
        def environment; end
        def environment_name; end
        def full_query; end
        def generator_url; end
        def gitlab_alert; end
        def gitlab_fingerprint; end
        def gitlab_prometheus_alert_id; end
        def gitlab_y_label; end
        def description; end
        def hosts; end
        def metric_id; end
        def metrics_dashboard_url; end
        def monitoring_tool; end
        def runbook; end
        def service; end
        def severity; end
        def starts_at; end
        def status; end
        def title; end

        def alert_params
          {
            project_id: project.id,
            title: title,
            description: description,
            monitoring_tool: monitoring_tool,
            payload: payload,
            started_at: starts_at,
            ended_at: ends_at,
            fingerprint: gitlab_fingerprint,
            environment: environment,
            prometheus_alert: gitlab_alert
          }.compact
        end

        private

        def parse_rfc3339(value)
          return unless value

          Time.rfc3339(value).utc
        rescue ArgumentError
        end

        def parse_time(value)
          return unless value

          Time.parse(value).utc
        rescue ArgumentError
        end
      end
    end
  end
end
