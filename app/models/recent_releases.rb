# frozen_string_literal: true

class RecentReleases
  def self.preload_for_milestones(milestones)
    releases = Release
      .select('releases.*')
      .from('(SELECT releases.*, milestone_releases.milestone_id, rank() OVER (PARTITION BY milestone_releases.milestone_id ORDER BY releases.released_at DESC) FROM releases JOIN milestone_releases ON releases.id = milestone_releases.release_id) AS releases')
      .where('rank <= 3')
      .where(milestone_id: milestones.pluck(:id))
      .group_by(&:milestone_id)

    milestones.map do |milestone|
      milestone.association(:recent_releases).loaded!
      milestone.association(:recent_releases).target.concat(Array(releases[milestone.id]))
    end
  end
end
