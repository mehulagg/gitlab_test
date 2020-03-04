# frozen_string_literal: true

module Clusters
  module Management
    class ApplyApplicationConfigService
      include Gitlab::Utils::StrongMemoize

      CONFIGURATION_FILE_PATH = '.gitlab/managed-apps/config.yaml'

      attr_reader :cluster, :user

      delegate :management_project, to: :cluster

      def initialize(cluster, user:)
        @cluster = cluster
        @user = user
      end

      def execute
        return false unless can_apply_configuration?

        file_operation_service.new(management_project, user, commit_params).execute
      end

      private

      def can_apply_configuration?
        management_project.present? && Feature.enabled?(:install_cluster_applications_via_management_project)
      end

      def existing_project_configuration
        strong_memoize(:existing_project_configuration) do
          blob = management_project.repository.blob_at(target_branch, CONFIGURATION_FILE_PATH)

          YAML.safe_load(blob.data.to_s)
        end
      end

      def persisted_configuration
        applications = cluster.persisted_applications.select(&:helmfile_install_supported?)
        applications.map(&:helmfile_configuration).reduce(&:merge)
      end

      def file_operation_service
        existing_project_configuration.present? ? Files::UpdateService : Files::CreateService
      end

      def commit_params
        {
          file_path: CONFIGURATION_FILE_PATH,
          commit_message: _('Update cluster management project'),
          file_content: existing_project_configuration.deep_merge(persisted_configuration).to_yaml,
          branch_name: target_branch,
          start_branch: target_branch
        }
      end

      def target_branch
        management_project.default_branch
      end
    end
  end
end
