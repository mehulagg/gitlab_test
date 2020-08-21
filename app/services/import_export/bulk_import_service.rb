# frozen_string_literal: true

# Takes a group ID and the credentials for a GitLab instance.
# Triggers an export on the other GitLab instance. Waits for
# the other instance to notify completion.

module ImportExport
  class BulkImportService
    attr_reader :group_id, :user, :client

    def initialize(group_id:, user:, host:, access_token:)
      @group_id = group_id
      @user = user

      # TODO: is this the best way to authenticate?
      @client = GitlabClient.new(host: host, access_token: access_token)
    end

    def execute
      client.start_export(group_id: group_id).success?
    end
  end
end
