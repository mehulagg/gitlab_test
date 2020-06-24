# frozen_string_literal: true

module AlertManagement
  class MappingService < BaseService
    delegate :alerts_service, :alerts_service_activated?, to: :project

    def execute(token)
      alert_payload = map_payload
      return bad_request unless alert_payload

      Projects::Alerting::NotifyService
        .new(project, current_user, alert_payload)
        .execute(token)
    end

    private

    def load_mapping
      name = params[:provider]
      template = Gitlab::Template::AlertMappingTemplate.find(name, project)
      return unless template

      config = Gitlab::Config::Loader::Yaml.new(template.content)
      Gitlab::AlertManagement::MappingConfig.from_yaml(config.load_raw!)
    rescue => e
      p e
      nil
    end

    def map_payload
      config = load_mapping
      return unless config

      payload = params[:payload]

      config.fields.to_h do |field|
        [field.name, map_payload_field(payload, field)]
      end.compact
    rescue Gitlab::Template::Finders::RepoTemplateFinder::FileNotFoundError 
    end

    def map_payload_field(payload, field)
      field.map_from.each do |key|
        # TODO support aray indexing like foo.bar[2].baz?
        result = payload.dig(*key.split('.'))
        return result if result
      end
    end

    def bad_request
      ServiceResponse.error(message: 'Bad Request', http_status: :bad_request)
    end
  end
end
