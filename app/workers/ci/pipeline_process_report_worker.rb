module Ci
  class PipelineProcessReportWorker
    include ApplicationWorker
    include PipelineBackgroundQueue

    idempotent!

    def perform(pipeline_id)
      Ci::Pipeline.find_by_id(pipeline_id).try do |pipeline|
        Ci::PipelineProcessReportService.new.execute(pipeline)
      end
    end
  end
end
