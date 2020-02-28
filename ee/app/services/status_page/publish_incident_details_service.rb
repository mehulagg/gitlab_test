# frozen_string_literal: true

module StatusPage
  class PublishIncidentDetailsService
    def initialize(storage_client:, serializer:)
      @storage_client = storage_client
      @serializer = serializer
    end

    def execute(issue, user_notes)
      json = serialize(issue, user_notes)
      key = object_key(json)
      return error('Missing incident key', issue: issue) unless key

      upload(key, json)
    end

    private

    attr_reader :storage_client, :serializer

    def serialize(issue, user_notes)
      serializer.represent_details(issue, user_notes)
    end

    def object_key(json)
      id = json[:id]
      return unless id

      StatusPage::Storage.details_path(id)
    end

    def upload(key, json)
      content = json.to_json

      storage_client.upload_object(key, content)

      success(object_key: key)
    rescue StatusPage::Storage::Error => e
      error(e.message, error: e)
    end

    def error(message, payload = {})
      ServiceResponse.error(message: message, payload: payload)
    end

    def success(payload = {})
      ServiceResponse.success(payload: payload)
    end
  end
end
