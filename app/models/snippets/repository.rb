# frozen_string_literal: true

module Snippets
  class Repository < ::Repository
    attr_reader :snippet

    def initialize(snippet)
      @snippet = snippet

      if snippet.project_id?
        full_path = snippet.project.full_path + snippet_suffix
        disk_path = snippet.project.disk_path + snippet_suffix
      else
        full_path = snippet.author.namespace.full_path + '/' + snippet.author.namespace.full_path + snippet_suffix
        disk_path = snippet.author.namespace.disk_path + snippet_suffix
      end

      super(full_path, snippet.project, disk_path: disk_path, repo_type: Gitlab::GlRepository::SNIPPET)
    end

    def subject
      snippet
    end

    private

    def snippet_suffix
      Gitlab::GlRepository::SNIPPET.path_suffix + '-' + snippet.id.to_s
    end

    def initialize_raw_repository
      repository_storage = snippet.project_id? ? snippet.project.repository_storage : snippet.author.namespace.repository_storage
      full_path = snippet.project_id? ? snippet.project.full_path : snippet.author.namespace.full_path

      Gitlab::Git::Repository.new(repository_storage,
                                  disk_path + '.git',
                                  repo_type.identifier_for_subject(snippet),
                                  full_path)
    end
  end
end
