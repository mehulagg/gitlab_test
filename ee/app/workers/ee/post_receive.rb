# frozen_string_literal: true

module EE
  # PostReceive EE mixin
  #
  # This module is intended to encapsulate EE-specific model logic
  # and be prepended in the `PostReceive` worker
  module PostReceive
    extend ActiveSupport::Concern

    private

    def after_project_changes_hooks(post_received, user, refs, changes)
      super

      if ::Gitlab::Geo.primary?
        ::Geo::RepositoryUpdatedService.new(post_received.project.repository, refs: refs, changes: changes).execute
      end
    end

    def process_wiki_changes(post_received)
      super

      update_wiki_es_indexes(post_received)

      if ::Gitlab::Geo.primary?
        ::Geo::RepositoryUpdatedService.new(post_received.project.wiki.repository).execute
      end
    end

    def update_wiki_es_indexes(post_received)
      return unless post_received.project.use_elasticsearch?

      post_received.project.wiki.index_blobs
    end
  end
end
