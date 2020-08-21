# frozen_string_literal: true

# Takes a group ID and the credentials for a GitLab instance.
# Triggers an export on the other GitLab instance. Waits for
# the other instance to notify completion.

module Groups
  module ImportExport
    class BulkImportService
      attr_reader :group_id, :user, :client

      def initialize(group_id:, user:, host:, access_token:)
        @group_id = group_id
        @user = user

        # TODO: is this the best way to authenticate?
        @client = Client.new(host: host, access_token: access_token)
      end

      def execute
        client.start_export(group_id: group_id).success?
      end

      private

      class Client
        attr_reader :host, :access_token

        def initialize(host:, access_token:)
          @host = host
          @access_token = access_token
        end

        def start_export(group_id:)
          Gitlab::HTTP.post(start_export_url(group_id),
            # body: content,
            allow_local_requests: true,
            headers: headers)
        end

        private

        def start_export_url(group_id)
          "#{host}/api/v4/groups/#{group_id}/bulk_export"
        end

        def headers
          {
            'Content-Type' => 'application/json',
            'PRIVATE-TOKEN' => access_token
          }
        end
      end
    end
  end
end
