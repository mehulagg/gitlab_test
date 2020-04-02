# frozen_string_literal: true

module Projects
  class CleanupIntegrationsService < BaseService
    def initialize(instance_level_service)
      @attributes = instance_level_service.attributes
      @attributes['instance'] = false
      @attributes.except!('id', 'project_id', 'created_at', 'updated_at')
    end

    def execute
      Service.where(@attributes).delete_all
    end
  end
end
