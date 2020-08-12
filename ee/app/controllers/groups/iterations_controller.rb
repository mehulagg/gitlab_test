# frozen_string_literal: true

class Groups::IterationsController < Groups::ApplicationController
  before_action :check_iterations_available!
  before_action :authorize_show_iteration!, only: [:index, :show]
  before_action :authorize_create_iteration!, only: :new
  before_action do
    push_frontend_feature_flag(:iteration_charts, group)
    push_frontend_feature_flag(:burnup_charts, group)
  end

  def index; end

  def show; end

  def new; end

  private

  def check_iterations_available!
    render_404 unless group.feature_available?(:iterations)
  end

  def authorize_create_iteration!
    render_404 unless can?(current_user, :create_iteration, group)
  end

  def authorize_show_iteration!
    render_404 unless can?(current_user, :read_iteration, group)
  end
end
