# frozen_string_literal: true

class ElasticCommitIndexerWorker
  include ApplicationWorker

  sidekiq_options retry: 2

  def perform(project_id, oldrev = nil, newrev = nil)
    return true unless Gitlab::CurrentSettings.elasticsearch_indexing?

    unlock_project(project_id) if oldrev == Gitlab::Git::BLANK_SHA

    project = Project.find(project_id)

    Gitlab::Elastic::Indexer.new(project).run(oldrev, newrev)
  end

  private

  def unlock_project(project_id)
    Gitlab::Redis::SharedState.with { |redis| redis.srem(:elastic_projects_indexing, project_id) }
  end
end
