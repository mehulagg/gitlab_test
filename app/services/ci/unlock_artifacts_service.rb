# frozen_string_literal: true

module Ci
  class UnlockArtifactsService < ::BaseService
    BATCH_SIZE = 100

    def execute(ci_ref, before_pipeline = nil)
      query = <<~SQL.squish
        UPDATE "ci_pipelines"
        SET    "locked" = #{::Ci::Pipeline.lockeds[:unlocked]}
        WHERE  "ci_pipelines"."id" in (
            #{collect_pipelines(ci_ref, before_pipeline).select(:id).to_sql}
            LIMIT  #{BATCH_SIZE}
            FOR  UPDATE SKIP LOCKED
        )
        RETURNING "ci_pipelines"."id";
      SQL

      loop do
        rows = ActiveRecord::Base.connection.exec_query(query).rows
        break if rows.empty?

        schedule_artifacts_removal(rows.flatten)
      end
    end

    private

    def collect_pipelines(ci_ref, before_pipeline)
      pipeline_scope = ci_ref.pipelines
      pipeline_scope = pipeline_scope.before_pipeline(before_pipeline) if before_pipeline

      pipeline_scope.artifacts_locked
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def schedule_artifacts_removal(pipeline_ids)
      Ci::JobArtifact
        .select(:id, :expire_at)
        .joins(:job)
        .merge(Ci::Build.where(pipeline_id: pipeline_ids))
        .where.not(expire_at: nil)
        .each_batch { |batch| Gitlab::Ci::JobArtifactsExpirationQueue.schedule_removal(batch) }
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
