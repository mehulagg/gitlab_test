# frozen_string_literal: true

module Clusters
  module Applications
    class InstallService < BaseHelmService
      def execute
        return unless app.scheduled?

        app.make_installing!

        issue_helm_command(:install, worker: ClusterWaitForAppInstallationWorker) do
          helm_api.install(install_command)
        end
      end
    end
  end
end
