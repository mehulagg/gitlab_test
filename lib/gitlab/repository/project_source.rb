# frozen_string_literal: true

module Gitlab
  module Repository
    # Git repository adapter for project source-code
    class ProjectSource < ::Repository
      # Runs code after a repository has been forked/imported.
      def after_import
        super

        DetectRepositoryLanguagesWorker.perform_async(project.id)
      end

      # temporary
      def repo_type
        ::Gitlab::GlRepository::RepoType.new(
          name: :project,
          access_checker_class: Gitlab::GitAccess,
          repository_resolver: -> (project) { project.repository }
        ).freeze
      end
    end
  end
end
