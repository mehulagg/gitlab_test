module Gitlab
  module AlertManagement
    module Payload
      MONITORING_TOOLS = {
        prometheus: 'Prometheus',
        generic: 'Generic'
      }.freeze

      class << self
        def parse(project, payload, monitoring_tool: nil)
          monitoring_tool ||= payload&.dig('monitoring_tool')

          klass = case monitoring_tool
                  when MONITORING_TOOLS[:prometheus]
                    if gitlab_managed_prometheus?(payload)
                      ::Gitlab::AlertManagement::Payload::ManagedPrometheus
                    else
                      ::Gitlab::AlertManagement::Payload::Prometheus
                    end
                  else
                    ::Gitlab::AlertManagement::Payload::Generic
                  end

          klass.new(project: project, payload: payload)
        end

        private

        def gitlab_managed_prometheus?(payload)
          payload&.dig('labels', 'gitlab_alert_id').present?
        end
      end
    end
  end
end
