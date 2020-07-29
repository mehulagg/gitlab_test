# frozen_string_literal: true

class Groups::ReleasesController < Groups::ApplicationController
  def index
    respond_to do |format|
      format.json { render json: releases }
    end
  end

  private

  def releases
    GroupReleasesFinder
      .new(group: @group, current_user: current_user, params: {}, options: { include_subgroups: false, preload: true })
      .execute
      .page(params[:page])
  end
end
