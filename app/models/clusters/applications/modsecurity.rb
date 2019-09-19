
# frozen_string_literal: true

module Clusters
  module Applications
    class Modsecurity < ApplicationRecord
      VERSION = '0.0.1'

      self.table_name = 'clusters_applications_modsecurities'

      include ::Clusters::Concerns::ApplicationCore
      include ::Clusters::Concerns::ApplicationStatus
      include ::Clusters::Concerns::ApplicationVersion
      include ::Clusters::Concerns::ApplicationData

      default_value_for :version, VERSION

      def set_initial_status
        return unless not_installable?
        return unless cluster&.application_ingress_available?

        ingress = cluster.application_ingress
        self.status = 'installable' if ingress.external_ip_or_hostname?
      end

      def chart
        "stable/modsecurity-blocking"
      end

      def repository
        # 'https://charts.gitlab.io'
        'https://theoretick.gitlab.io/'
      end

      def values
        content_values.to_yaml
      end

      def install_command
        Gitlab::Kubernetes::Helm::InstallCommand.new(
          name: name,
          version: VERSION,
          rbac: cluster.platform_kubernetes_rbac?,
          chart: chart,
          files: files,
          repository: repository
        )
      end

      def uninstall_command
        #  TODO: revert changes to modsecurity file
      end

      private

      def specification
        {}
      end

      def content_values
        YAML.load_file(chart_values_file).deep_merge!(specification)
      end
    end
  end
end
