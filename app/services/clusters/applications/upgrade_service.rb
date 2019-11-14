# frozen_string_literal: true

module Clusters
  module Applications
    class UpgradeService < BaseHelmService
      def execute
        return unless app.scheduled?

        app.make_updating!

        issue_helm_command(:upgrade, worker: ClusterWaitForAppInstallationWorker) do
          helm_api.update(install_command)
        end
      end
    end
  end
end
