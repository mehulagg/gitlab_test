# frozen_string_literal: true

class ResetProjectCacheService < ::ContainerBaseService
  def execute
    @project.increment!(:jobs_cache_index)
  end
end
