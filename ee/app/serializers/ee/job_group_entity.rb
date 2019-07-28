# frozen_string_literal: true

module EE
  module JobGroupEntity
    extend ActiveSupport::Concern

    prepended do
      expose :duration, if: -> (group, opts) { opts[:timings] && can_read_pipeline_timings? } do |group|
        jobs_ordered_by_started_at = group.jobs.reject { |job| job.started_at.nil? || job.retried? }.sort_by(&:started_at)

        ::Gitlab::Ci::Pipeline::Duration.from_builds(jobs_ordered_by_started_at)
      end
    end

    private

    def can_read_pipeline_timings?
      true
    end
  end
end
