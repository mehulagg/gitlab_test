# frozen_string_literal: true

class ElasticCommitIndexerWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker

  feature_category :global_search
  sidekiq_options retry: 2
  urgency :throttled

  # TODO: _oldrev is unused but kept for backwards-compatibility,
  # this can be removed in the next major release.
  def perform(project_id, _oldrev = nil, newrev = nil, wiki = false)
    return true unless Gitlab::CurrentSettings.elasticsearch_indexing?

    project = Project.find(project_id)

    return true unless project.use_elasticsearch?

    Gitlab::Elastic::Indexer.run(project, to_sha: newrev, wiki: wiki)
  end
end
