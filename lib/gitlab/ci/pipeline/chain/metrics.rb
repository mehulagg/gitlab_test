# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        class Metrics < Chain::Base
          def perform!
            counter = Gitlab::Metrics.counter(:pipelines_created_total, "Counter of pipelines created")
            counter.increment(source: @pipeline.source)
          end

          def perform_on_dry_run?
            false
          end

          def break?
            false
          end
        end
      end
    end
  end
end
