# frozen_string_literal: true

module Security
  class StoreScansWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include SecurityScansQueue

    # rubocop: disable CodeReuse/ActiveRecord
    def perform(pipeline_id)
      ::Ci::Pipeline.find_by(id: pipeline_id).try do |pipeline|
        break unless pipeline.project.can_store_security_reports?

        Security::StoreScansService.new(pipeline).execute
      end
    end
  end
end
