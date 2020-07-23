# frozen_string_literal: true

class Projects::IncidentsController < Projects::ApplicationController
  before_action :authorize_read_incidents!
  before_action do
    push_frontend_feature_flag(:incident_details, project)
  end

  def index
  end

  def details
    return render_404 unless Feature.enabled?(:incident_details, project)

    @incident_id = params[:id]
  end
end
