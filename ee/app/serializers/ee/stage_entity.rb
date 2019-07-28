# frozen_string_literal: true

module EE
  module StageEntity
    extend ActiveSupport::Concern

    prepended do
      expose :duration, if: -> (stage, opts) { opts[:timings] && can_read_pipeline_timings? } do |stage|
        statuses_ordered_by_started_at = stage.statuses.reject { |job| job.started_at.nil? || job.retried? }.sort_by(&:started_at)

        ::Gitlab::Ci::Pipeline::Duration.from_builds(statuses_ordered_by_started_at)
      end
    end

    private

    def can_read_pipeline_timings?
      true
    end
  end
end
