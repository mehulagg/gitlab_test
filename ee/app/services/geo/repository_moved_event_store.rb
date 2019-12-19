# frozen_string_literal: true

module Geo
  class RepositoryMovedEventStore < EventStore
    self.event_type = :repository_moved_event

    private

    def build_event
      Geo::RepositoryMovedEvent.new(
        project: project,
        old_repository_storage: old_repository_storage_name,
        new_repository_storage: project.repository.storage
      )
    end

    def old_repository_storage_name
      params.fetch(:old_repository_storage_name)
    end
  end
end
