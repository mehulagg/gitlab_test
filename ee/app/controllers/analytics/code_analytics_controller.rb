# frozen_string_literal: true

class Analytics::CodeAnalyticsController < Analytics::ApplicationController
  include RoutableActions

  CONFIDENTIAL_ACCESS_LEVEL = Gitlab::Access::REPORTER

  before_action :load_group
  before_action :load_project
  before_action :check_feature_availability!
  before_action :authorize_view_code_analytics!
  before_action :validate_params

  def show
    respond_to do |format|
      format.html
      format.json { render json: hotspots_tree, status: :ok }
    end
  end

  private

  def hotspots_tree
    Analytics::HotspotsTree.new.build(Analytics::CodeAnalyticsFinder.new(@project, @from, @to).execute)
  end

  def from_and_to
    case code_analytics_params['timeframe']
    when "last_30_days"
      [30.days.ago.to_datetime, Time.now.to_datetime]
    else
      nil
    end
  end

  def authorize_view_code_analytics!
    return render_403 unless can?(current_user, :view_code_analytics, @group || :global)
  end

def check_feature_availability!
    return render_404 unless ::License.feature_available?(:code_analytics)
    return render_404 if @group && !@group.root_ancestor.feature_available?(:code_analytics)
  end

  def load_group
    return unless params['group_id']

    @group = find_routable!(Group, params['group_id'])
  end

  def load_project
    return unless @group && params['project_id']

    @project = find_routable!(@group.projects, params['project_id'])
  end

  def validate_params
    unless @group
      return render json: "Selected group not found with user's access level.", status: :forbidden
    end

    unless @project
      return render json: "Selected project not found with user's access level.", status: :forbidden
    end

    @from, @to = from_and_to
    unless @from && @to
      return render json: "Invalid timeframe.", status: :unprocessable_entity
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
