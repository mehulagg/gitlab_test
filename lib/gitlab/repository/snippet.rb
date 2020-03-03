# frozen_string_literal: true

module Gitlab
  module Repository
    # Git repository adapter for snippets
    class Snippet < ::Repository
      # temporary
      def repo_type
        ::Gitlab::GlRepository::RepoType.new(
          name: :snippet,
          access_checker_class: Gitlab::GitAccessSnippet,
          repository_resolver: -> (snippet) { snippet.repository },
          container_resolver: -> (id) { ::Snippet.find_by_id(id) }
        ).freeze
      end

      def project
        container.project
      end
    end
  end
end
