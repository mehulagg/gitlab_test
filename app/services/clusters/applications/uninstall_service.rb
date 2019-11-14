# frozen_string_literal: true

module Clusters
  module Applications
    class UninstallService < BaseHelmService
      def execute
        return unless app.scheduled?

        app.make_uninstalling!

        issue_helm_command(:uninstall, worker: Clusters::Applications::WaitForUninstallAppWorker) do
          helm_api.uninstall(app.uninstall_command)
        end
      end
    end
  end
end
