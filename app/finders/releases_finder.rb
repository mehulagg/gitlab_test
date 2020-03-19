# frozen_string_literal: true

class ReleasesFinder
  attr_accessor :project, :current_user, :params

  def initialize(project, current_user = nil, params = {})
    @project = project
    @current_user = current_user
    @params = params
  end

  def execute(preload: true)
    return Release.none unless Ability.allowed?(current_user, :read_release, project)

    releases = by_tag(project.releases)
    releases = releases.preloaded if preload
    releases.sorted
  end

  private

  # rubocop: disable CodeReuse/ActiveRecord
  def by_tag(releases)
    return releases unless params[:tag]

    releases.where(tag: params[:tag])
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
