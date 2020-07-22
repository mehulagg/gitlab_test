# frozen_string_literal: true

class Projects::IncidentsController < Projects::ApplicationController
  before_action :authorize_read_incidents!

  def index
  end

  def details
    @incident_id = params[:id]
  end
end
