# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # Create missing LfsObjectsProject records for a given project (e.g. forks).
    class LinkLfsObjects
      # Model specifically needed for this migration. Some code needed
      # for this migration were copied from the Project model.
      class Project < ActiveRecord::Base
        include Routable

        HASHED_STORAGE_FEATURES = {
          repository: 1
        }.freeze

        self.table_name = 'projects'

        belongs_to :namespace

        has_many :lfs_objects_projects, class_name: 'LfsObjectsProject'

        has_many \
          :lfs_objects,
          -> { distinct },
          through: :lfs_objects_projects,
          class_name: 'LfsObject'

        alias_method :parent, :namespace

        delegate :disk_path, to: :storage

        def hashed_storage?(feature)
          self.storage_version && self.storage_version >= HASHED_STORAGE_FEATURES[feature]
        end

        def repository
          @repository ||= Repository.new(full_path, self, disk_path: disk_path)
        end

        def storage
          @storage ||=
            if hashed_storage?(:repository)
              Storage::Hashed.new(self)
            else
              Storage::LegacyProject.new(self)
            end
        end
      end

      # Model used specifically for this migration.
      class LfsObjectsProject < ActiveRecord::Base
        self.table_name = 'lfs_objects_projects'
      end

      # Model used specifically for this migration.
      class LfsObject < ActiveRecord::Base
        self.table_name = 'lfs_objects'

        def self.not_linked_to_project(project)
          where(
            'NOT EXISTS (?)',
            project
              .lfs_objects_projects
              .select(1)
              .where('lfs_objects_projects.lfs_object_id = lfs_objects.id')
          )
        end
      end

      BATCH_SIZE = 1000

      def perform(project_ids)
        projects = Project.where(id: project_ids)

        return if projects.empty?

        projects.find_each do |project|
          link_existing_lfs_objects(project)
        end
      end

      private

      def link_existing_lfs_objects(project)
        project_lfs_oids = lfs_oids(project)

        return if project_lfs_oids.empty?

        project_lfs_oids.each_slice(BATCH_SIZE) do |oids|
          rows =
            LfsObject
              .where(oid: oids)
              .not_linked_to_project(project)
              .map { |obj| { project_id: project.id, lfs_object_id: obj.id } }

          next if rows.empty?

          Gitlab::Database.bulk_insert(LfsObjectsProject.table_name, rows)
        end
      end

      def lfs_oids(project)
        project
          .repository
          .gitaly_blob_client
          .get_all_lfs_pointers('HEAD')
          .map(&:lfs_oid)
      rescue GRPC::NotFound
        []
      end
    end
  end
end
