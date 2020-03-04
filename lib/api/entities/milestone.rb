# frozen_string_literal: true

module API
  module Entities
    class Milestone < MilestoneBasic
      expose :issue_stats do
        expose(:total)  { |milestone, options| milestone.total_issue_count(options[:current_user]) }
        expose(:closed) { |milestone, options| milestone.closed_issue_count(options[:current_user]) }
      end
    end
  end
end
