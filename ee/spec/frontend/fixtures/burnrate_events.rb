# frozen_string_literal: true

require 'spec_helper'

describe 'Burnrate charts (JavaScript fixtures)', type: :request do
  include JavaScriptFixturesHelpers
  include ApiHelpers

  let(:user) { create(:user) }
  let!(:project) { create(:project, namespace: user.namespace) }
  let!(:milestone) { create(:milestone, project: project, title: 'Milestone', description: 'Burndown example', start_date: Date.today, due_date: Date.today + 3.days) }
  let!(:issue_1) { create(:issue, created_at: Date.today.beginning_of_day, project: project, milestone: milestone, weight: 2) }
  let!(:issue_2) { create(:issue, created_at: Date.today.middle_of_day, project: project, milestone: milestone, weight: 3) }
  let!(:issue_3) { create(:issue, created_at: Date.today.middle_of_day, project: project, milestone: milestone, weight: 2) }

  before(:all) do
    # clean_frontend_fixtures('burnrate_events/')
  end

  before do
    project.add_developer(user)
  end

  it 'burndown_events.json' do
    get api("/projects/#{project.id}/milestones/#{milestone.id}/burndown_events", user)

    expect(response).to be_successful
  end
end