# frozen_string_literal: true

# Controller for viewing a file's raw
class Projects::IdeController < Projects::ApplicationController
  def show
    @ref = params[:ref]
  end
end
