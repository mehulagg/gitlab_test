# frozen_string_literal: true

module Snippets
  class UpdateStatisticsService
    attr_reader :snippet

    def initialize(snippet)
      @snippet = snippet
    end

    def execute
      unless snippet.repository_exists?
        return ServiceResponse.error(message: 'Invalid snippet repository', http_status: 400)
      end

      snippet.repository.expire_statistics_caches
      statistics.refresh!

      # Update project statistics if the snippet is a Project one
      if snippet.project_id
        ProjectCacheWorker.perform_async(snippet.project_id, [], [:snippets_size])
      end

      ServiceResponse.success(message: 'Snippet statistics successfully updated.')
    end

    private

    def statistics
      @statistics ||= snippet.statistics || snippet.build_statistics
    end
  end
end
