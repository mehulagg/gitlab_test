# frozen_string_literal: true

module Gitlab
  module Geo
    module LogCursor
      module Events
        class RepositoryMovedEvent
          include BaseEvent

          def process
            return unless event.project_id

            job_id = moved_repository_storage unless skippable?
            log_event(job_id)
          end

          private

          def moved_repository_storage
            # Must always schedule, regardless of shard health
            ::Geo::MoveRepositoryStorageService.new(
              event.project_id,
              event.old_repository_storage,
              event.new_repository_storage
            ).async_execute
          end

          def log_event(job_id)
            logger.event_info(
              created_at,
              'Moving project storage',
              project_id: event.project_id,
              old_storage: event.old_repository_storage,
              new_storage: event.new_repository_storage,
              skippable: skippable?,
              job_id: job_id)
          end
        end
      end
    end
  end
end
