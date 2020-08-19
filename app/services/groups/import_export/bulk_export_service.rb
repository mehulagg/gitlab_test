# frozen_string_literal: true

module Groups
  module ImportExport
    class BulkExportService
      attr_reader :group, :user

      def initialize(group:, user:)
        @group = group
        @user = user
      end

      def async_execute
        ::ImportExport::GroupExportWorker.perform_async(user.id, group.id)
      end

      def execute
        # export top level namespace
        Groups::ImportExport::ExportService.new(group: group, user: user).execute

        # triggers jobs to export all descendant projects
        Project.where(group: all_groups).find_each do |project|
          ProjectExportWorker.perform_async(user.id, project.id)
        end

        # notify/callback that the group has been exported

        true
      end

      private

      def all_groups
        @all_groups ||= Gitlab::ObjectHierarchy
          .new(::Group.where(id: group.id))
          .base_and_descendants(with_depth: true)
          .order_by(:depth)
      end
    end
  end
end
