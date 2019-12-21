# frozen_string_literal: true

module EE
  module Projects
    module HashedStorage
      module MigrateRepositoryService
        extend ::Gitlab::Utils::Override

        override :execute
        def execute
          super do
            replicator.publish(:project_storage_migrated,
                               old_storage_version: old_storage_version,
                               old_disk_path: old_disk_path,
                               old_wiki_disk_path: old_wiki_disk_path)
          end
        end

        def replicator
          HashedStorageReplicator.new(model: project)
        end
      end
    end
  end
end
