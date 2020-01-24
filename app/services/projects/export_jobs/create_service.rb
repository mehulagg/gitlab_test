# frozen_string_literal: true

module Projects
  module ExportJobs
    class CreateService < BaseService
      def execute(job_id)
        # rubocop: disable CodeReuse/ActiveRecord
        export_job = project.export_jobs.find_by(jid: job_id)
        # rubocop: enable CodeReuse/ActiveRecord
        return export_job if export_job.present?

        export_job = project.export_jobs.new(jid: job_id)

        export_job.tap do |job|
          job.save

          job.start
        end
      end
    end
  end
end
