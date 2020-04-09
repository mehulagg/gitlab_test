# frozen_string_literal: true

require 'spec_helper'

describe Burnup do
  describe '#burnup_data' do
    before do
      stub_licensed_features(epics: true)
    end

    let!(:user) { create(:user) }

    let!(:project) { create(:project, :public) }

    let!(:start_date) { Date.parse('2020-01-04') }
    let!(:due_date) { Date.parse('2020-01-26') }

    let!(:milestone1) { create(:milestone, :with_dates, title: 'v1.0', project: project, start_date: start_date, due_date: due_date) }
    let!(:milestone2) { create(:milestone, :with_dates, title: 'v1.1', project: project, start_date: start_date + 1.year, due_date: due_date + 1.year) }

    let!(:issue1) { create(:issue, project: project, milestone: milestone1) }
    let!(:issue2) { create(:issue, project: project, milestone: milestone1) }
    let!(:issue3) { create(:issue, project: project, milestone: milestone1) }
    let!(:other_issue) { create(:issue, project: project) }

    let!(:event1) { create(:resource_milestone_event, issue: issue1, action: :add, milestone: milestone1, created_at: start_date) }
    let!(:event2) { create(:resource_milestone_event, issue: issue2, action: :add, milestone: milestone1, created_at: start_date) }
    let!(:event3) { create(:resource_milestone_event, issue: issue3, action: :add, milestone: milestone1, created_at: start_date) }
    let!(:event4) { create(:resource_milestone_event, issue: issue3, action: :remove, milestone: nil, created_at: start_date + 2.hours) }

    it 'returns the expected data points' do
      # These events are ignored
      create(:resource_milestone_event, issue: other_issue, action: :remove, milestone: milestone2, created_at: start_date.beginning_of_day - 1.second)
      create(:resource_milestone_event, issue: issue1, action: :add, milestone: milestone2, created_at: start_date.beginning_of_day - 1.second)
      create(:resource_milestone_event, issue: issue3, action: :remove, milestone: nil, created_at: due_date.end_of_day + 1.second)

      data = described_class.new(milestone1, visible_issues: [issue1, issue2, issue3]).burnup_data

      expect(data.size).to eq(4)

      expect_milestone_event(data[0], action: 'add', issue_id: issue1.id, milestone_id: milestone1.id, created_at: start_date)
      expect_milestone_event(data[1], action: 'add', issue_id: issue2.id, milestone_id: milestone1.id, created_at: start_date)
      expect_milestone_event(data[2], action: 'add', issue_id: issue3.id, milestone_id: milestone1.id, created_at: start_date)
      expect_milestone_event(data[3], action: 'remove', issue_id: issue3.id, created_at: start_date + 2.hours)
    end

    it 'excludes issues which are not in the visible list' do
      data = described_class.new(milestone1, visible_issues: [issue2]).burnup_data

      expect(data.size).to eq(1)

      expect_milestone_event(data[0], action: 'add', issue_id: issue2.id, milestone_id: milestone1.id, created_at: start_date)
    end

    def expect_milestone_event(event, with_properties)
      expect(event[:event_type]).to eq('milestone')

      expect_to_match_each_property(event, with_properties)
    end

    def expect_to_match_each_property(event, properties)
      properties.each do |key, value|
        expect(event[key]).to eq(value)
      end
    end
  end
end
