# frozen_string_literal: true

class Groups::ReleasesController < Groups::ApplicationController
  def index
    respond_to do |format|
      format.json { render json: releases }
    end
  end

  private

  def releases
    projects_releases = []
    group = Namespace.includes(projects: :releases).where.not(releases: { tag: nil }).find(@group.id) # rubocop: disable CodeReuse/ActiveRecord
    group.projects.each do |project|
      if Ability.allowed?(current_user, :read_release, project)
        projects_releases = projects_releases.concat(project.releases)
      end
    end
    projects_releases.sort_by { |release| release[:released_at] }.reverse!
  end
end
