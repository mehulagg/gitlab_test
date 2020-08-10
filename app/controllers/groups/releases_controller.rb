# frozen_string_literal: true

class Groups::ReleasesController < Groups::ApplicationController
  def index
    respond_to do |format|
      format.json do
        render json: ::ReleaseSerializer.new.represent(releases, current_user: current_user)
      end
    end
  end

  private

  def releases
    ReleasesFinder
      .new(@group, current_user, { include_subgroups: true })
      .execute
      .page(params[:page])
      .per(30)
  end
end
