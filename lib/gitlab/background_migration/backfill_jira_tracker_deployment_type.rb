# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # Backfill the deployment_type in jira_tracker_data table
    class BackfillJiraTrackerDeploymentType
      # Migration only version of jira_tracker_data table
      class JiraTrackerDataTemp < ActiveRecord::Base
        self.table_name = 'jira_tracker_data'

        attr_encrypted :url, { key: Settings.attr_encrypted_db_key_base_32, encode: true, mode: :per_attribute_iv, algorithm: 'aes-256-gcm' }
        attr_encrypted :api_url, { key: Settings.attr_encrypted_db_key_base_32, encode: true, mode: :per_attribute_iv, algorithm: 'aes-256-gcm' }
        enum deployment_type: { unknown: 0, server: 1, cloud: 2 }, _prefix: :deployment

        belongs_to :service, class_name: 'JiraServiceTemp'
      end

      # Migration only version of services table
      class JiraServiceTemp < ActiveRecord::Base
        self.table_name = 'services'
        self.inheritance_column = :_type_disabled
      end

      def perform(tracker_id)
        @jira_tracker_data = JiraTrackerDataTemp.find_by(id: tracker_id, deployment_type: 0)

        return unless jira_tracker_data&.service&.active
        return unless client_url

        update_deployment_type
      end

      private

      attr_reader :jira_tracker_data

      def options
        url = URI.parse(client_url)

        {
          # we don't need to authenticate since the serverInfo API is public
          site: URI.join(url, '/').to_s, # Intended to find the root
          context_path: url.path,
          read_timeout: 120,
          use_ssl: url.scheme == 'https'
        }
      end

      def client
        @client ||= begin
                      JIRA::Client.new(options).tap do |client|
                        client.request_client = Gitlab::Jira::HttpClient.new(client.options)
                      end
                    end
      end

      def client_url
        jira_tracker_data.api_url&.delete_suffix('/').presence ||
          jira_tracker_data.url&.delete_suffix('/').presence
      end

      def jira_request
        yield
      rescue => error
        @error = error
        log_error('Error querying Jira', error: @error.message)
        nil
      end

      def server_info
        client_url.present? ? jira_request { client.ServerInfo.all.attrs } : nil
      end

      def update_deployment_type
        results = server_info
        return unless results.present?

        case results['deploymentType']
        when 'Server'
          jira_tracker_data.deployment_server!
        when 'Cloud'
          jira_tracker_data.deployment_cloud!
        else
          jira_tracker_data.deployment_unknown!
        end
      end

      def log_error(message, params = {})
        ::Gitlab::BackgroundMigration::Logger.error(
          migrator: 'BackfillJiraTrackerDeploymentType',
          message: message,
          jira_service_id: jira_tracker_data.service&.id,
          project_id: jira_tracker_data.service&.project_id,
          client_url: client_url,
          error: params[:error]
        )
      end
    end
  end
end
