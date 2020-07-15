# frozen_string_literal: true

module Gitlab
  module Geo
    module LogCursor
      module Events
        class DesignRepositoryUpdatedEvent
          include BaseEvent

          def process
            job_id =
              unless skippable?
                registry.repository_updated!
                schedule_job(event)
              end

            log_event(job_id)
          end

          private

          def registry
            @registry ||= ::Geo::DesignRegistry.safe_find_or_create_by(project_id: event.project_id)
          end

          def schedule_job(event)
            enqueue_job_if_shard_healthy(event) do
              ::Geo::DesignRepositorySyncWorker.perform_async(event.project_id)
            end
          end

          def log_event(job_id)
            super(
              'Design repository update',
              project_id: event.project_id,
              scheduled_at: Time.current,
              skippable: skippable?,
              job_id: job_id)
          end
        end
      end
    end
  end
end
