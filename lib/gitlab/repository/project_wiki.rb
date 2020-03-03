# frozen_string_literal: true

module Gitlab
  module Repository
    # Git repository adapter for project wiki content
    class ProjectWiki < ::Repository
      # temporary
      def repo_type
        ::Gitlab::GlRepository::RepoType.new(
          name: :wiki,
          access_checker_class: Gitlab::GitAccessWiki,
          repository_resolver: -> (project) { project.wiki.repository },
          suffix: :wiki
        ).freeze
      end
    end
  end
end
