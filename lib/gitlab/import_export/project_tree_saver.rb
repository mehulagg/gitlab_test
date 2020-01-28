# frozen_string_literal: true

module Gitlab
  module ImportExport
    class ProjectTreeSaver
      def initialize(project:, current_user:, shared:, params: {})
        @params       = params
        @project      = project
        @current_user = current_user
        @shared       = shared
      end

      def save
        savers = []
        savers << ImportExport::JSON::NdjsonWriter.new(File.join(@shared.export_path, "tree"), :project)
        savers << ImportExport::JSON::LegacyWriter.new(File.join(@shared.export_path, "project.json"))

        serializer = ImportExport::JSON::StreamingSerializer.new(@project, reader.project_tree)
        serializer.overrides['description'] = @params[:description] if @params[:description].present?
        serializer.additional_relations['project_members'] = group_members_array
        serializer.execute(savers)

        true
      ensure
        savers.each(&:close)
      #rescue => e
      #  @shared.error(e)
      #  false
      end

      private

      def reader
        @reader ||= Gitlab::ImportExport::Reader.new(shared: @shared)
      end

      def group_members_array
        group_members.as_json(reader.group_members_tree).each do |group_member|
          group_member['source_type'] = 'Project' # Make group members project members of the future import
        end
      end

      def group_members
        return [] unless @current_user.can?(:admin_group, @project.group)

        # We need `.where.not(user_id: nil)` here otherwise when a group has an
        # invitee, it would make the following query return 0 rows since a NULL
        # user_id would be present in the subquery
        # See http://stackoverflow.com/questions/129077/not-in-clause-and-null-values
        non_null_user_ids = @project.project_members.where.not(user_id: nil).select(:user_id)

        GroupMembersFinder.new(@project.group).execute.where.not(user_id: non_null_user_ids)
      end
    end
  end
end
