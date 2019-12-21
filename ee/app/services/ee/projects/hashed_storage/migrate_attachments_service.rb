# frozen_string_literal: true

module EE
  module Projects
    module HashedStorage
      module MigrateAttachmentsService
        extend ::Gitlab::Utils::Override

        override :execute
        def execute
          super do
            break true if skipped?

            replicator.publish(:attachments_storage_migrated,
                               old_attachments_path: old_disk_path,
                               new_attachments_path: new_disk_path)
          end
        end

        def replicator
          HashedStorageReplicator.new(model: project)
        end
      end
    end
  end
end
