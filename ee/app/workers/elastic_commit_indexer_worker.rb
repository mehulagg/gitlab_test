# frozen_string_literal: true

class ElasticCommitIndexerWorker
  include ApplicationWorker

  feature_category :search
  sidekiq_options retry: 2

  # TODO: _oldrev is unused but kept for backwards-compatibility,
  # this can be removed in the next major release.
  def perform(project_id, _oldrev = nil, newrev = nil, wiki = false)
    return true unless Gitlab::CurrentSettings.elasticsearch_indexing?

    project = Project.find(project_id)

    return true unless project.use_elasticsearch?

    Gitlab::Elastic::Indexer.run(project, to_sha: newrev, wiki: wiki)
  end
end
