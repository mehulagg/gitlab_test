# frozen_string_literal: true

module Clusters
  module Applications
    class Cilium < ApplicationRecord
      VERSION = '0.0.1'

      self.table_name = 'clusters_applications_cilium'

      include ::Clusters::Concerns::ApplicationCore
      include ::Clusters::Concerns::ApplicationStatus
      include ::Clusters::Concerns::ApplicationVersion
      include ::Clusters::Concerns::ApplicationData

      default_value_for :version, VERSION

      def chart
        ""
      end

      def repository
        ""
      end
  
      def install_command
        Gitlab::Kubernetes::Helm::InstallCommand.new(
          name: name,
          version: VERSION,
          rbac: cluster.platform_kubernetes_rbac?,
          chart: chart,
          repository: repository
        )
      end
    end
  end
end