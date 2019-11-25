# frozen_string_literal: true

module Gitlab
  module Geo
    module Replicable
      module Strategies
        module Repository
          module Events
            class UpdateEvent
              include ::Gitlab::Geo::LogHelpers

              def self.create_for(repository)
                ::Geo::ReplicableEvent.create!(event_class_name: self.name, registry_class_name: repository.replicable_registry_class, model_id: repository.project.id)
              end

              def initialize(replicable_event)
                @registry_class = replicable_event.registry_class_name.constantize
                @model_id = replicable_event.model_id
                @created_at = replicable_event.created_at
              end

              def consume
                job_id =
                  unless skippable?
                    registry

                    schedule_sync
                  end

                log_event(job_id)
              end

              private

              attr_reader :registry_class, :model_id, :created_at

              def registry
                @registry ||= registry_class.safe_find_or_create_by("#{registry_class.foreign_key}": model_id)
              end

              def schedule_sync
                registry.enqueue_sync
              end

              def skippable?
                registry_class.skippable?
              end

              def log_event(job_id)
                log_info(
                  '#consume',
                  created_at: created_at,
                  registry_class: registry_class.to_s,
                  model_id: model_id,
                  scheduled_at: Time.now,
                  skippable: skippable?,
                  job_id: job_id)
              end
            end
          end
        end
      end
    end
  end
end
