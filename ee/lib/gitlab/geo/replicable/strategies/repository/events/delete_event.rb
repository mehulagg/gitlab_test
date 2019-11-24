module Gitlab
  module Geo
    module Replicable
      module Strategies
        module Repository
          module Events
            class DeleteEvent
              include ::Gitlab::Geo::LogHelpers

              def self.create_for(repository)
                ::Geo::ReplicableEvent.create!(
                  event_class_name: self.name,
                  registry_class_name: repository.replicable_registry_class,
                  model_id: repository.project.id,
                  payload: {
                    repository_storage_name: repository.storage,
                    deleted_path: repository.disk_path
                  }
                )
              end

              def initialize(replicable_event)
                @registry_class = replicable_event.registry_class_name.constantize
                @model_id = replicable_event.model_id
                @created_at = replicable_event.created_at
                @repository_storage_name = replicable_event.payload['repository_storage_name']
                @deleted_path = replicable_event.payload['deleted_path']
              end

              def consume
                job_id =
                  unless skippable?
                    registry.enqueue_delete(repository_storage_name, deleted_path)
                  end

                log_event(job_id)
              end

              private

              attr_reader :registry_class, :model_id, :created_at, :repository_storage_name, :deleted_path

              def registry
                @registry ||= registry_class.safe_find_or_create_by("#{registry_class.foreign_key}": model_id)
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
                  repository_storage_name: repository_storage_name,
                  deleted_path: deleted_path,
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
