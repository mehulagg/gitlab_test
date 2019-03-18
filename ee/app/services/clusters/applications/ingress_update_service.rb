# frozen_string_literal: true

module Clusters
  module Applications
    class IngressUpdateService < BaseHelmService
      attr_accessor :project

      def initialize(app, project)
        super(app)
        @project = project
      end

      def execute
        app.make_updating!

        helm_api.update(upgrade_command(app.values))

        ::ClusterWaitForAppUpdateWorker.perform_in(::ClusterWaitForAppUpdateWorker::INTERVAL, app.name, app.id)
      rescue ::Kubeclient::HttpError => ke
        app.make_update_errored!("Kubernetes error: #{ke.message}")
      rescue StandardError => e
        app.make_update_errored!(e.message)
      end
    end
  end
end
