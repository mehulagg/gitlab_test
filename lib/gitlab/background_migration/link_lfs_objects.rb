# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # Create missing LfsObjectsProject records for forks
    class LinkLfsObjects
      # Model definition used for migration
      class ForkNetworkMember < ActiveRecord::Base
        include EachBatch

        self.table_name = 'fork_network_members'

        def self.with_incomplete_lfs_objects
          where(
            <<~SQL
              EXISTS (
                SELECT 1
                FROM lfs_objects_projects source_lop
                LEFT JOIN lfs_objects_projects lop ON lop.lfs_object_id = source_lop.lfs_object_id
                AND lop.project_id = fork_network_members.project_id
                WHERE lop.project_id IS NULL
                AND source_lop.project_id = fork_network_members.forked_from_project_id
              )
            SQL
          )
        end
      end

      # Model definition used for migration
      class Project < ActiveRecord::Base
        include EachBatch

        self.table_name = 'projects'

        has_one :fork_network_member, class_name: 'LinkLfsObjects::ForkNetworkMember'

        def self.with_incomplete_lfs_objects
          fork_network_members =
            ForkNetworkMember.with_incomplete_lfs_objects
              .select(1)
              .where('fork_network_members.project_id = projects.id')

          where('EXISTS (?)', fork_network_members)
        end
      end

      # Model definition used for migration
      class LfsObjectsProject < ActiveRecord::Base
        include EachBatch

        self.table_name = 'lfs_objects_projects'

        def self.not_linked_to_project(project)
          where(
            <<~SQL
              lfs_objects_projects.lfs_object_id NOT IN (
                SELECT lop.lfs_object_id
                FROM lfs_objects_projects lop
                WHERE lop.project_id = #{project.id}
              )
            SQL
          )
        end
      end

      BATCH_SIZE = 1000

      def perform(start_id, end_id)
        forks =
          Project
            .with_incomplete_lfs_objects
            .where(id: start_id..end_id)

        forks.includes(:fork_network_member).find_each do |project|
          LfsObjectsProject
            .select("lfs_objects_projects.lfs_object_id, #{project.id}, NOW(), NOW()")
            .not_linked_to_project(project)
            .where(project_id: project.fork_network_member.forked_from_project_id)
            .each_batch(of: BATCH_SIZE) do |batch|
              execute <<~SQL
                INSERT INTO lfs_objects_projects (lfs_object_id, project_id, created_at, updated_at)
                #{batch.to_sql}
              SQL
            end
        end

        logger.info(message: "LinkLfsObjects: created missing LfsObjectsProject for Projects #{forks.map(&:id).join(', ')}")
      end

      private

      def execute(sql)
        ::ActiveRecord::Base.connection.execute(sql)
      end

      def logger
        @logger ||= Gitlab::BackgroundMigration::Logger.build
      end
    end
  end
end
