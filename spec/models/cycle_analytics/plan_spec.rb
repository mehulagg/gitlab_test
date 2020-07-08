# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'CycleAnalytics#plan' do
  extend CycleAnalyticsHelpers::TestGeneration

  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:from_date) { 10.days.ago }
  let_it_be(:user) { project.owner }
  let_it_be(:project_level) { CycleAnalytics::ProjectLevel.new(project, options: { from: from_date }) }

  subject { project_level }

  generate_cycle_analytics_spec(
    phase: :plan,
    data_fn: -> (context) do
      {
        issue: context.build(:issue, project: context.project),
        branch_name: context.generate(:branch)
      }
    end,
    start_time_conditions: [["issue associated with a milestone",
                             -> (context, data) do
                               data[:issue].update(milestone: context.create(:milestone, project: context.project))
                             end],
                            ["list label added to issue",
                             -> (context, data) do
                               data[:issue].update(label_ids: [context.create(:list).label_id])
                             end]],
    end_time_conditions:   [["issue mentioned in a commit",
                             -> (context, data) do
                               context.create_commit_referencing_issue(data[:issue], branch_name: data[:branch_name])
                             end]],
    post_fn: -> (context, data) do
    end)

  context "when a regular label (instead of a list label) is added to the issue" do
    it "returns nil" do
      branch_name = generate(:branch)
      label = create(:label)
      issue = create(:issue, project: project)
      issue.update(label_ids: [label.id])
      create_commit_referencing_issue(issue, branch_name: branch_name)

      create_merge_request_closing_issue(user, project, issue, source_branch: branch_name)
      merge_merge_requests_closing_issue(user, project, issue)

      expect(subject[:issue].project_median).to be_nil
    end
  end
end
