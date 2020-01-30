# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        module PersistentRules
          class Base
            def can_persist_skip?
              raise NotimplementedError
            end

            def can_persist_error?(failure_reason)
              raise NotimplementedError
            end
          end
        end
      end
    end
  end
end
