# frozen_string_literal: true

module Projects
  module Integrations
    module Jira
      IntegrationError = Class.new(StandardError)
      RequestError = Class.new(StandardError)

      PER_PAGE = 100

      class IssuesFinder < ::Jira::Requests::Base
        extend ::Gitlab::Utils::Override

        attr_reader :issues, :total_count

        def initialize(project, params = {})
          @project = project
          @jira_service = project&.jira_service
          @project_key = jira_service&.project_key
          @page = params[:page].presence || 1
          @params = params

          super(jira_service, params)
        end

        def execute
          return [] unless Feature.enabled?(:jira_integration, project)

          raise IntegrationError, _('Jira service not configured.') unless jira_service&.active?
          raise IntegrationError, _('Jira project key is not configured') if project_key.blank?

          @jql = ::Integrations::Jira::JqlBuilder.new(project_key, params).jql

          handle_response(super)
        end

        private

        attr_reader :project, :jira_service, :project_key, :page, :params, :jql

        def handle_response(response)
          if response.success?
            @total_count = response.payload[:total_count]
            @issues = response.payload[:issues]
          else
            raise RequestError, response.message
          end
        end

        override :url
        def url
          "#{base_api_url}/search?jql=#{CGI.escape(jql)}&startAt=#{start_at}&maxResults=#{PER_PAGE}&fields=*all"
        end

        override :build_service_response
        def build_service_response(response)
          return ServiceResponse.success(payload: empty_payload) if response.blank? || response["issues"].blank?

          ServiceResponse.success(payload: {
            issues: map_issues(response["issues"]),
            is_last: last?(response),
            total_count: response["total"].to_i
          })
        end

        def map_issues(response)
          response.map { |v| JIRA::Resource::Issue.build(client, v) }
        end

        def empty_payload
          { issues: [], is_last: true, total_count: 0 }
        end

        def last?(response)
          response["total"].to_i <= response["startAt"].to_i + response["issues"].size
        end

        def start_at
          (page - 1) * PER_PAGE
        end
      end
    end
  end
end
