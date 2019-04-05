# frozen_string_literal: true

class ElasticCommitIndexerWorker
  include ApplicationWorker

  sidekiq_options retry: 2

  def perform(project_id, oldrev = nil, newrev = nil)
    return true unless Gitlab::CurrentSettings.elasticsearch_indexing?

    project = Project.find(project_id)

    return true unless project.use_elasticsearch?

    Gitlab::Elastic::Indexer.new(project).run(newrev)
  end
end
