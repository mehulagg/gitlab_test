# frozen_string_literal: true
module EE
  module IssueEntity
    extend ActiveSupport::Concern

    prepended do
      expose :weight, if: ->(issue, _) { issue.supports_weight? }
      expose :blocked_by_issues
    end
  end
end
