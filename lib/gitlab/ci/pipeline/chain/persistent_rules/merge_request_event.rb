# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        module PersistentRules
          class MergeRequestEvent < Base
            def can_persist_skip?
              true
            end

            def can_persist_error?(failure_reason)
              failure_reason != :config_error
            end
          end
        end
      end
    end
  end
end
