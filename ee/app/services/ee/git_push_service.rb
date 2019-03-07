# frozen_string_literal: true

module EE
  module GitPushService
    extend ::Gitlab::Utils::Override

    protected

    override :execute_related_hooks
    def execute_related_hooks
      if ::Gitlab::CurrentSettings.elasticsearch_indexing? && default_branch? && should_index_commits?
        newrev = params[:newrev]

        if params[:oldrev] == ::Gitlab::Git::BLANK_SHA
          # Lock the project. This is a brand new repo and we don't want subsequent pushes to cause the
          # possibly big initial push not to be indexed (Possible if the repo is large)
          # We also set `params[:newrev]` to `nil` so that the Elastic indexer indexes everything up to the newest
          # commit. This way any pushes that occur during the time the project is locked will still be indexed.
          ::Gitlab::Redis::SharedState.with { |redis| redis.sadd(:elastic_projects_indexing, project.id) }
          newrev = nil
        end

        ::ElasticCommitIndexerWorker.perform_async(project.id, params[:oldrev], newrev)
      end

      super
    end

    private

    def should_index_commits?
      ::Gitlab::Redis::SharedState.with { |redis| !redis.sismember(:elastic_projects_indexing, project.id) }
    end

    override :pipeline_options
    def pipeline_options
      { mirror_update: project.mirror? && project.repository.up_to_date_with_upstream?(branch_name) }
    end
  end
end
