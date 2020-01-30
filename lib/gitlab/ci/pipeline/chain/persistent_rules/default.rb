# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        module PersistentRules
          class Default < Base
            def can_persist_skip?
              true
            end

            def can_persist_error?(failure_reason)
              true
            end
          end
        end
      end
    end
  end
end
