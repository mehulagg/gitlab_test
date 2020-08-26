module ImportExport
  class GitlabClient
    # TODO: split this file into separate source and destination clients (so that host is not confusing)

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

    def notify_export(importable_type:, importable_id:, destination_group_id:, params: {})
      Gitlab::HTTP.post(
        callback_url,
        body: {
          importable_type: importable_type,
          importable_id: importable_id,
          destination_group_id: destination_group_id,
          importable_params: params
        }.to_json,
        allow_local_requests: true,
        headers: headers
      )
    end

    def download_export_file_url(source_type, source_id)
      "#{host}/api/v4/#{source_type.to_s.pluralize}/#{source_id}/export/download"
    end

    def headers
      {
        'Content-Type' => 'application/json',
        'PRIVATE-TOKEN' => access_token
      }
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
  end
end
