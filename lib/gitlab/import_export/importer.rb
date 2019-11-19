# frozen_string_literal: true

module Gitlab
  module ImportExport
    class Importer
      include Gitlab::Allowable
      include Gitlab::Utils::StrongMemoize

      def self.imports_repository?
        true
      end

      def initialize(project)
        @archive_file = project.import_source
        @current_user = project.creator
        @project = project
        @shared = project.import_export_shared
      end

      def execute
        if import_file && check_version! && restorers.all?(&:restore) && overwrite_project
          project
        else
          raise Projects::ImportService::Error.new(shared.errors.to_sentence)
        end
      rescue => e
        raise Projects::ImportService::Error.new(e.message)
      ensure
        remove_import_file
      end

      private

      attr_accessor :archive_file, :current_user, :project, :shared

      def restorers
        import_manager.restorers
      end

      def import_manager
        @import_manager ||= VersionManager.import_manager_klass_for_version(shared.version).new(project: project)
      end

      def import_file
        import_manager.import_file
      end

      def check_version!
        VersionChecker.check!
      end

      def path_with_namespace
        File.join(project.namespace.full_path, project.path)
      end

      def remove_import_file
        upload = project.import_export_upload

        return unless upload&.import_file&.file

        upload.remove_import_file!
        upload.save!
      end

      def overwrite_project
        return unless can?(current_user, :admin_namespace, project.namespace)

        if overwrite_project?
          ::Projects::OverwriteProjectService.new(project, current_user)
                                             .execute(project_to_overwrite)
        end

        true
      end

      def original_path
        project.import_data&.data&.fetch('original_path', nil)
      end

      def overwrite_project?
        original_path.present? && project_to_overwrite.present?
      end

      def project_to_overwrite
        strong_memoize(:project_to_overwrite) do
          Project.find_by_full_path("#{project.namespace.full_path}/#{original_path}")
        end
      end
    end
  end
end
