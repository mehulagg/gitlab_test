# frozen_string_literal: true

module EE
  module Gitlab
    module QuickActions
      module MergeRequestHelpers
        def mergeable?
          super &&
            (!quick_action_target.approval_needed? || quick_action_target.approved?)
        end
      end
    end
  end
end
