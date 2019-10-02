# frozen_string_literal: true

class Analytics::CodeAnalyticsController < Analytics::ApplicationController
  CONFIDENTIAL_ACCESS_LEVEL = Gitlab::Access::REPORTER

  before_action :load_group
  before_action :load_project

  before_action -> {
    check_feature_availability!(:code_analytics)
  }

  before_action -> {
    authorize_view_productivity_analytics!(:view_code_analytics)
  }

  before_action :validate_params

  def show
    respond_to do |format|
      format.html
      format.json { render json: hotspots_tree, status: :ok }
    end
  end

  private

  def hotspots_tree
    Analytics::CodeAnalytics::HotspotsTree.new(Analytics::CodeAnalyticsFinder.new(@project, @from, @to).execute).build
  end

  def from_and_to
    case code_analytics_params['timeframe']
    when 'last_30_days'
      [30.days.ago.to_datetime, Time.now.to_datetime]
    else
      nil
    end
  end

  def validate_params
    unless @group
      return render json: 'Selected group not found with user\'s access level.', status: :forbidden
    end

    unless @project
      return render json: 'Selected project not found with user\'s access level.', status: :forbidden
    end

    @from, @to = from_and_to
    unless @from && @to
      return render json: 'Invalid timeframe.', status: :unprocessable_entity
    end
  end

  def code_analytics_params
    params.permit(code_analytics_params_attributes)
  end

  def code_analytics_params_attributes
    %i[
      group_id
      project_id
      timeframe
    ]
  end
end
