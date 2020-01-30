# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        module PersistentRules
          class Schedule < Base
            def can_persist_skip?
              false
            end

            def can_persist_error?(failure_reason)
              false
            end
          end
        end
      end
    end
  end
end
