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
    @group.projects.each do |project|
      projects_releases = projects_releases.concat(ReleasesFinder.new(project, current_user).execute)
    end
    projects_releases.sort_by { |project| project[:released_at] }.reverse!
  end
end
