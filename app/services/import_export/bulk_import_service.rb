# frozen_string_literal: true

# Takes a group ID and the credentials for a GitLab instance.
# Triggers an export on the other GitLab instance. Waits for
# the other instance to notify completion.

module ImportExport
  class BulkImportService
    attr_reader :group_id, :user, :host, :access_token, :destination_group_params

    def initialize(group_id:, user:, host:, access_token:, destination_group_params:)
      @group_id = group_id
      @user = user
      @host = host
      @access_token = access_token

      @destination_group_params = destination_group_params
    end

    def execute
      # TODO: validate that the URL is okay first?
      group = ::Groups::CreateService.new(user, params).execute

      if group.persisted?
        group.create_bulk_import!(source_host: host, user: user, private_token: access_token)

        client.start_export(
          source_group_id: group_id,
          destination_group_id: group.full_path
        ).success?
      end
    end

    private

    def client
      @client ||= GitlabClient.new(host: host, access_token: access_token)
    end

    def params
      {
        path: destination_group_params[:path],
        name: destination_group_params[:name],
        parent_id: destination_group_params[:parent_id],
        visibility_level: closest_allowed_visibility_level
      }
    end

    def closest_allowed_visibility_level
      if parent_group
        Gitlab::VisibilityLevel.closest_allowed_level(parent_group.visibility_level)
      else
        Gitlab::VisibilityLevel::PRIVATE
      end
    end

    def parent_group
      find_group!(destination_group_params[:parent_id]) if destination_group_params[:parent_id].present?
    end
  end
end
