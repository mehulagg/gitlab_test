# frozen_string_literal: true

module Analytics
  class InstanceActivity

    def pipelines_created
      pipeline_created_counter.get(source: :web) # change to a regex \*\
    end

    def pipeline_created_counter
      @pipeline_created_counter ||= Gitlab::Metrics
        .counter(:pipelines_created_total, "Counter of pipelines created")
    end
  end
end