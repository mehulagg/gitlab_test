# frozen_string_literal: true

class Projects::Environments::SampleMetricsController < Projects::ApplicationController
  rescue_from(Metrics::SampleMetricsService::MissingSampleMetricsFile) do
    render_404
  end

  def query
    result = Metrics::SampleMetricsService.new(params[:identifier], start_range: params[:start], end_range: params[:end]).query
    render json: { "status": "success", "data": { "resultType": "matrix", "result": result } }
  end
end
