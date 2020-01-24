# frozen_string_literal: true

module Gitlab
  module ImportExport
    class SnippetRepoSaver < RepoSaver
      def initialize(project:, shared:, repository:)
        @project = project
        @shared = shared
        @repository = repository
      end

      private

      def bundle_full_path
        File.join(shared.export_path, ::Gitlab::ImportExport.snippet_repo_bundle_dir, "#{repository.container.hexdigest}.bundle")
      end
    end
  end
end
