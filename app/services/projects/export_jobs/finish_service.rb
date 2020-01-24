# frozen_string_literal: true

module Projects
  module ExportJobs
    class FinishService < BaseService
      def execute(export_job)
        status = export_job.finish

        if status
          log_info("Export for project #{project.id} finished successfully")
        else
          log_error("Failed to update export status for project #{project.id} to finished")
        end
      end
    end
  end
end
