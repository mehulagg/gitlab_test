# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        module Helpers
          def skip
            @pipeline.skip if persistent_rule.can_persist_skip?
          end

          ##
          # failure_reason must be one of Ci::Pipeline.failure_reasons.
          def error(message, failure_reason = nil)
            if failure_reason && persistent_rule.can_persist_error?(failure_reason)
              pipeline.yaml_errors = message if failure_reason == :config_error
              pipeline.drop!(failure_reason)
            end

            pipeline.errors.add(:base, message)
          end

          private

          def persistent_rule
            @persistent_rule ||= Chain::PersistentRule.fabricate(@pipeline.source)
          end
        end
      end
    end
  end
end
