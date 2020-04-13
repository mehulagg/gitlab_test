# frozen_string_literal: true

require 'spec_helper'

describe Burnup do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }

  let!(:project) { create(:project, :private) }

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
  let!(:event3) { create(:resource_milestone_event, issue: issue3, action: :add, milestone: milestone1, created_at: start_date + 1.day) }
  let!(:event4) { create(:resource_milestone_event, issue: issue3, action: :remove, milestone: nil, created_at: start_date + 2.days + 1.second) }

  before do
    project.add_maintainer(user)
  end

  describe '#initialize' do
    it 'respects a given custom time frame' do
      date1 = Date.parse('2020-02-14')
      date2 = Date.parse('2020-02-15')

      instance = described_class.new(milestone: milestone1, user: user, start_date: date1, end_date: date2)

      expect(instance.start_date).to eq(date1)
      expect(instance.end_date).to eq(date2)
    end

    it 'ignores an invalid time frame' do
      date1 = Date.parse('2020-02-14')
      date2 = Date.parse('2020-02-15')

      instance = described_class.new(milestone: milestone1, user: user, start_date: date2, end_date: date1)

      expect(instance.start_date).to eq(milestone1.start_date)
      expect(instance.end_date).to eq(milestone1.due_date)
    end

    it 'ignores provided time frame if nil start_date is provided' do
      date1 = Date.parse('2020-02-15')

      instance = described_class.new(milestone: milestone1, user: user, start_date: nil, end_date: date1)

      expect(instance.start_date).to eq(milestone1.start_date)
      expect(instance.end_date).to eq(milestone1.due_date)
    end

    it 'ignores provided time frame if nil end_date is provided' do
      date1 = Date.parse('2020-02-15')

      instance = described_class.new(milestone: milestone1, user: user, start_date: date1, end_date: nil)

      expect(instance.start_date).to eq(milestone1.start_date)
      expect(instance.end_date).to eq(milestone1.due_date)
    end

    it 'ignores provided time frame if nil for start_date and end_date is provided' do
      instance = described_class.new(milestone: milestone1, user: user, start_date: nil, end_date: nil)

      expect(instance.start_date).to eq(milestone1.start_date)
      expect(instance.end_date).to eq(milestone1.due_date)
    end
  end

  describe '#burnup_events' do
    it 'returns the expected events' do
      # These events are ignored
      create(:resource_milestone_event, issue: other_issue, action: :remove, milestone: milestone2, created_at: start_date.beginning_of_day - 1.second)
      create(:resource_milestone_event, issue: issue1, action: :add, milestone: milestone2, created_at: start_date.beginning_of_day - 1.second)
      create(:resource_milestone_event, issue: issue3, action: :remove, milestone: nil, created_at: due_date.end_of_day + 1.second)

      data = described_class.new(milestone: milestone1, user: user).burnup_events

      expect(data.size).to eq(4)

      expect_milestone_event(data[0], action: 'add', issue_id: issue1.id, milestone_id: milestone1.id, created_at: start_date)
      expect_milestone_event(data[1], action: 'add', issue_id: issue2.id, milestone_id: milestone1.id, created_at: start_date)
      expect_milestone_event(data[2], action: 'add', issue_id: issue3.id, milestone_id: milestone1.id, created_at: start_date + 1.day)
      expect_milestone_event(data[3], action: 'remove', issue_id: issue3.id, created_at: start_date + 2.days + 1.second)
    end

    it 'returns the expected events if a custom time frame is provided' do
      create(:resource_milestone_event, issue: issue2, action: :remove, milestone: milestone1, created_at: start_date + 1.day + 1.second)

      data = described_class.new(milestone: milestone1, user: user, start_date: start_date + 1.day, end_date: start_date + 2.days).burnup_events

      expect(data.size).to eq(3)

      expect_milestone_event(data[0], action: 'add', issue_id: issue3.id, milestone_id: milestone1.id, created_at: start_date + 1.day)
      expect_milestone_event(data[1], action: 'remove', issue_id: issue2.id, created_at: start_date + 1.day + 1.second)
      expect_milestone_event(data[2], action: 'remove', issue_id: issue3.id, created_at: start_date + 2.days + 1.second)
    end

    it 'excludes issues which should not be visible to the user ' do
      data = described_class.new(milestone: milestone1, user: other_user).burnup_events

      expect(data).to be_empty
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
