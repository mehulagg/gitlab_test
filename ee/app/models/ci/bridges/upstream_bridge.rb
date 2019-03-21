# frozen_string_literal: true

module Ci
  module Bridges
    class UpstreamBridge < Ci::Bridge
      state_machine :status do
        after_transition created: :pending do |bridge|
          bridge.run_after_commit do
            bridge.success!
          end
        end
      end

      def upstream_project_path
        options&.dig(:triggered_by, :project)
      end
    end
  end
end
