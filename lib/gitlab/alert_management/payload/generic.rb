# frozen_string_literal: true

module Gitlab
  module AlertManagement
    module Payload
      class Generic < Base
        add_attribute :title,
                      paths: [['title']],
                      fallback: Proc.new { 'New: Incident' }
        add_attribute :severity,
                      paths: [['severity']],
                      fallback: Proc.new { 'critical' }
        add_attribute :monitoring_tool,
                      paths: [['monitoring_tool']]
        add_attribute :service,
                      paths: [['service']]
        add_attribute :hosts,
                      paths: [['hosts']]
        add_attribute :plain_gitlab_fingerprint,
                      paths: [['fingerprint']]
        add_attribute :starts_at,
                      paths: [['start_time']],
                      type: :time
        add_attribute :runbook,
                      paths: [['runbook']],
                      type: :time
      end
    end
  end
end
