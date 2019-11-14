# frozen_string_literal: true

module Clusters
  module Applications
    class PatchService < BaseHelmService
      def execute
        return unless app.scheduled?

        app.make_updating!

        issue_helm_command(:patch, worker: ClusterWaitForAppInstallationWorker) do
          helm_api.update(update_command)
        end
      end
    end
  end
end
