# frozen_string_literal: true

require 'spec_helper'

describe RecentReleases do
  describe '.preload_for_milestones' do
    it 'preloads recent releases for all milestones' do
      project = create(:project)
      release_a = create(:release, project: project, released_at: Time.zone.parse('2018-10-01T16:00:00Z'))
      release_b = create(:release, project: project, released_at: Time.zone.parse('2018-10-02T16:00:00Z'))
      release_c = create(:release, project: project, released_at: Time.zone.parse('2018-10-03T16:00:00Z'))
      release_d = create(:release, project: project, released_at: Time.zone.parse('2018-10-04T16:00:00Z'))
      release_e = create(:release, project: project, released_at: Time.zone.parse('2018-10-05T16:00:00Z'))
      milestone_a = create(:milestone, project: project, releases: [release_a, release_b, release_c, release_d])
      milestone_b = create(:milestone, project: project, releases: [release_e])
      milestones = Milestone.all

      described_class.preload_for_milestones(milestones)

      fetched_milestone_a = milestones.find { |m| m.id == milestone_a.id }
      fetched_milestone_b = milestones.find { |m| m.id == milestone_b.id }
      expect(fetched_milestone_a.recent_releases.map(&:id)).to contain_exactly(release_d.id, release_c.id, release_b.id)
      expect(fetched_milestone_b.recent_releases.map(&:id)).to contain_exactly(release_e.id)
    end

    it 'preloads recent releases' do
      project = create(:project)
      release = create(:release, project: project, released_at: Time.zone.parse('2018-10-01T16:00:00Z'))
      create(:milestone, project: project, releases: [release])
      milestones = Milestone.all

      described_class.preload_for_milestones(milestones)
      fetched_milestone = milestones.first
      recorder = ActiveRecord::QueryRecorder.new { fetched_milestone.recent_releases.to_a }

      expect(recorder.count).to eq(0)
    end
  end
end
