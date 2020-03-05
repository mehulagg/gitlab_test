# frozen_string_literal: true

module API
  module Entities
    class Milestone < MilestoneBasic
      expose :issue_stats do
        # TODO: remove nil and change to `expose :as`
        # after https://gitlab.com/gitlab-org/gitlab/-/merge_requests/21554 is merged
        expose(:total)  { |milestone, options| milestone.total_issues_count(nil) }
        expose(:closed) { |milestone, options| milestone.closed_issues_count(nil) }
      end
    end
  end
end
