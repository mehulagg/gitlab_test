# frozen_string_literal: true

module Gitlab
  module ImportExport
    class ExportManager

      def initialize(**args)
        @project, @current_user, @params = args[:project], args[:user], args[:params].dup
      end

      def exporters
        [version_saver, avatar_saver, project_tree_saver, uploads_saver, repo_saver, wiki_repo_saver, lfs_saver]
      end

      private

      attr_accessor :project, :current_user, :params, :shared

      def version_saver
        VersionSaver.new(shared: shared)
      end

      def avatar_saver
        AvatarSaver.new(project: project, shared: shared)
      end

      def project_tree_saver
        ProjectTreeSaver.new(project: project, current_user: current_user, shared: shared, params: params)
      end

      def uploads_saver
        UploadsSaver.new(project: project, shared: shared)
      end

      def repo_saver
        RepoSaver.new(project: project, shared: shared)
      end

      def wiki_repo_saver
        WikiRepoSaver.new(project: project, shared: shared)
      end

      def lfs_saver
        LfsSaver.new(project: project, shared: shared)
      end
    end
  end
end
Projects::ImportExport::ExportManager.prepend_if_ee('EE::Projects::ImportExport::ExportManager')
