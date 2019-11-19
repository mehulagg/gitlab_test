# frozen_string_literal: true

module Gitlab
  module ImportExport
    class ImportManager
      def initialize(**args)
        @project = args[:project]
        @archive_file = project.import_source
        @current_user = project.creator
        @shared = project.import_export_shared
      end

      def restorers
        [repo_restorer, wiki_restorer, project_tree_restorer, avatar_restorer,
         uploads_restorer, lfs_restorer, statistics_restorer]
      end

      def import_file
        FileImporter.import(project: project,
                            archive_file: archive_file,
                            shared: shared)
      end

      private

      attr_accessor :archive_file, :current_user, :project, :shared

      def project_tree_restorer
        @project_tree ||= ProjectTreeRestorer.new(user: current_user,
                                                  shared: shared,
                                                  project: project)
      end

      def avatar_restorer
        AvatarRestorer.new(project: project, shared: shared)
      end

      def repo_restorer
        RepoRestorer.new(path_to_bundle: repo_path,
                                            shared: shared,
                                            project: project)
      end

      def wiki_restorer
        WikiRestorer.new(path_to_bundle: wiki_repo_path,
                                            shared: shared,
                                            project: ProjectWiki.new(project),
                                            wiki_enabled: project.wiki_enabled?)
      end

      def uploads_restorer
        UploadsRestorer.new(project: project, shared: shared)
      end

      def lfs_restorer
        LfsRestorer.new(project: project, shared: shared)
      end

      def statistics_restorer
        StatisticsRestorer.new(project: project, shared: shared)
      end

      def repo_path
        File.join(shared.export_path, ImportExport.project_bundle_filename)
      end

      def wiki_repo_path
        File.join(shared.export_path, ImportExport.wiki_repo_bundle_filename)
      end

    end
  end
end

Gitlab::ImportExport::ImportManager.prepend_if_ee('EE::Gitlab::ImportExport::ImportManager')
