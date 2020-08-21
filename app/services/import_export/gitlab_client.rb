module ImportExport
  class GitlabClient
    attr_reader :host, :access_token

    def initialize(host:, access_token: nil)
      @host = host
      @access_token = access_token
    end

    def start_export(source_group_id:, destination_group_id:)
      Gitlab::HTTP.post(
        start_export_url(source_group_id),
        body: { callback_host: callback_host, destination_group_id: destination_group_id }.to_json,
        allow_local_requests: true,
        headers: headers
      )
    end

    def notify_export(importable_type:, importable_id:, destination_group_id:)
      Gitlab::HTTP.post(
        callback_url,
        body: {
          importable_type: importable_type,
          importable_id: importable_id,
          destination_group_id: destination_group_id
        }.to_json,
        allow_local_requests: true,
        headers: headers
      )
    end

    private

    def callback_url
      "#{host}/api/v4/groups/export_status"
    end

    def callback_host
      Gitlab.config.gitlab.url
    end

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
