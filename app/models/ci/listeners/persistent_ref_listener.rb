# frozen_string_literal: true

module Ci
  class PersistentRefListener
    def self.handle_event(event, data)
      # In this case is acceptable to `find` and use a pipeline
      # object because we are still inside the `Ci` domain.
      pipeline = Ci::Pipeline.find_by_id(data[:pipeline_id])
      return unless pipeline

      pipeline.persistent_ref.delete
    end
  end
end
