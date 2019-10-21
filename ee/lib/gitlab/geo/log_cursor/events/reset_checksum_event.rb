# frozen_string_literal: true

module Gitlab
  module Geo
    module LogCursor
      module Events
        class ResetChecksumEvent
          include BaseEvent

          REPOSITORY_TYPES = %(repository wiki).freeze

          def process
            if REPOSITORY_TYPES.include?(event.resource_type) && !skippable?
              registry.reset_checksum!(event.resource_type)
            end

            log_event
          end

          private

          def log_event
            logger.event_info(
              created_at,
              'Reset checksum',
              project_id: event.project_id,
              resource_type: event.resource_type,
              skippable: skippable?
            )
          end
        end
      end
    end
  end
end
