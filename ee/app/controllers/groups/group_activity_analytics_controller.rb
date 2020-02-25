# frozen_string_literal: true

class Groups::GroupActivityAnalyticsController < Groups::ApplicationController
  before_action :check_feature_flag
  before_action :group

  layout 'group'

  def show
    respond_to do |format|
      format.html
      format.json do
        render json: GroupActivityAnalytics::DataCOllector.new(group).data
      end
    end
  end

  private

  def check_feature_flag
    render_404 unless Feature.enabled?(:group_activity_analytics)
  end
end
