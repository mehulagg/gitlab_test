# frozen_string_literal: true

module Snippets
  class Repository < ::Repository
    attr_reader :snippet

    def initialize(project, snippet)
      @snippet = snippet

      full_path = project.full_path + snippet_suffix
      disk_path = project.disk_path + snippet_suffix

      super(full_path, project, disk_path: disk_path, repo_type: Gitlab::GlRepository::SNIPPET)
    end

    private

    def snippet_suffix
      Gitlab::GlRepository::SNIPPET.path_suffix + '-' + snippet.id.to_s
    end

    def initialize_raw_repository
      Gitlab::Git::Repository.new(project.repository_storage,
                                  disk_path + '.git',
                                  repo_type.identifier_for_subject(snippet),
                                  project.full_path)
    end
  end
end
