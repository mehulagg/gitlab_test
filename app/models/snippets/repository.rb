# frozen_string_literal: true

module Snippets
  class Repository < ::Repository
    # We still need to override project because it is
    # defined in the parent class.
    # At some point, the main class Repository will remove the project
    # reference and work only with container
    delegate :project, to: :container

    def initialize(snippet)
      super(snippet.full_path, snippet, disk_path: snippet.disk_path, repo_type: Gitlab::GlRepository::SNIPPET)
    end
  end
end
