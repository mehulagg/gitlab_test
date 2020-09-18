# frozen_string_literal: true

module EE
  module Gitlab
    module GeoGitAccess
      include ::Gitlab::ConfigHelper
      include ::EE::GitlabRoutingHelper # rubocop: disable Cop/InjectEnterpriseEditionModule
      include GrapePathHelpers::NamedRouteMatcher
      extend ::Gitlab::Utils::Override

      GEO_SERVER_DOCS_URL = 'https://docs.gitlab.com/ee/administration/geo/replication/using_a_geo_server.html'.freeze

      protected

      def project_or_wiki
        container
      end

      private

      def geo_custom_action
        return unless geo_custom_action?

        payload = {
          'action' => 'geo_proxy_to_primary',
          'data' => {
            'api_endpoints' => custom_action_api_endpoints_for(cmd),
            'primary_repo' => primary_http_repo_url
          }
        }

        ::Gitlab::GitAccessResult::CustomAction.new(payload, messages)
      end

      def geo_custom_action?
        return unless ::Gitlab::Database.read_only?
        return unless ::Gitlab::Geo.secondary_with_primary?

        receive_pack? || upload_pack_and_not_replicated?
      end

      def upload_pack_and_not_replicated?
        return false unless project

        upload_pack? && !::Geo::ProjectRegistry.repository_replicated_for?(project.id)
      end

      def messages
        messages = ::Gitlab::Geo.interacting_with_primary_message(primary_ssh_url_to_repo).split("\n")
        lag_message = current_replication_lag_message

        return messages unless lag_message

        messages + ['', lag_message]
      end

      def push_to_read_only_message
        message = super

        if ::Gitlab::Geo.secondary_with_primary?
          message = "#{message}\nPlease use the primary node URL instead: #{geo_primary_url_to_repo}.\nFor more information: #{GEO_SERVER_DOCS_URL}"
        end

        message
      end

      def geo_primary_url_to_repo
        case protocol
        when 'ssh'
          geo_primary_ssh_url_to_repo(project_or_wiki)
        else
          geo_primary_http_url_to_repo(project_or_wiki)
        end
      end

      def primary_http_repo_url
        geo_primary_http_url_to_repo(project_or_wiki)
      end

      def primary_ssh_url_to_repo
        geo_primary_ssh_url_to_repo(project_or_wiki)
      end

      def current_replication_lag_message
        return if ::Gitlab::Database.read_write? || current_replication_lag == 0

        "Current replication lag: #{current_replication_lag} seconds"
      end

      def current_replication_lag
        @current_replication_lag ||= ::Gitlab::Geo::HealthCheck.new.db_replication_lag_seconds
      end

      def custom_action_api_endpoints_for(cmd)
        receive_pack? ? custom_action_push_api_endpoints : custom_action_pull_api_endpoints
      end

      def custom_action_pull_api_endpoints
        [
         api_v4_geo_proxy_git_ssh_info_refs_upload_pack_path,
         api_v4_geo_proxy_git_ssh_upload_pack_path
        ]
      end

      def custom_action_push_api_endpoints
        [
          api_v4_geo_proxy_git_ssh_info_refs_receive_pack_path,
          api_v4_geo_proxy_git_ssh_receive_pack_path
        ]
      end
    end
  end
end
