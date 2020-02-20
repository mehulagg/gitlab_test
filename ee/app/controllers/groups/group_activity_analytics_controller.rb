# frozen_string_literal: true

class Groups::GroupActivityAnalyticsController < Groups::ApplicationController
  before_action :group
  before_action :check_group_activity_analytics_available!

  layout 'group'

  def show
    respond_to do |format|
      format.html
      format.json
    end
  end

  private

  def check_contribution_analytics_available!
    render_404 unless @group.feature_available?(:group_activity_analytics)
  end
end
