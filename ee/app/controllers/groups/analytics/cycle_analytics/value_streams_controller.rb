# frozen_string_literal: true

class Groups::Analytics::CycleAnalytics::ValueStreamsController < Analytics::ApplicationController
  respond_to :json

  check_feature_flag Gitlab::Analytics::CYCLE_ANALYTICS_FEATURE_FLAG

  before_action :load_group
  before_action do
    render_403 unless can?(current_user, :read_group_cycle_analytics, @group)
  end

  def index
    render json: @group.group_value_streams.map { |value_stream| Analytics::GroupValueStreamSerializer.new.represent(value_stream) }
  end

  def create
    group_value_stream = @group.group_value_streams.build(group_value_stream_params)

    if group_value_stream.save
      render json: Analytics::GroupValueStreamSerializer.new.represent(group_value_stream)
    else
      render json: { errors: group_value_stream.errors }, status: :unprocessable_entity
    end
  end

  def group_value_stream_params
    params.require(:value_stream).permit(:name)
  end
end
