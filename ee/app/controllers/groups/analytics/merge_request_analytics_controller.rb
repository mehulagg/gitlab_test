# frozen_string_literal: true

class Groups::Analytics::MergeRequestAnalyticsController < Groups::Analytics::ApplicationController
  include Analytics::UniqueVisitsHelper

  layout 'group'

  before_action :load_group
  before_action :check_feature_flag
  before_action -> {
    check_feature_availability!(:group_merge_request_analytics)
  }
  before_action -> {
    authorize_view_by_action!(:read_group_merge_request_analytics)
  }

  track_unique_visits :show, target_id: 'g_analytics_merge_request'

  def show
  end

  private

  def check_feature_flag
    render_404 unless Feature.enabled?(:group_merge_request_analytics, @group)
  end
end
