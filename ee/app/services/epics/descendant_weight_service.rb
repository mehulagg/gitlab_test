# frozen_string_literal: true

module Epics
  class DescendantWeightService < DescendantService
    def opened_issues
      issues_weight_total.fetch(Epic.state_ids[:opened], 0)
    end

    def closed_issues
      issues_weight_total.fetch(Epic.state_ids[:closed], 0)
    end

    private

    def issues_weight_total
      strong_memoize(:issues_weight_total) do
        IssuesFinder.new(current_user).execute.in_epics(accessible_epics).weight_total_by_state
      end
    end
  end
end
