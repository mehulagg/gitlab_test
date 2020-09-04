# frozen_string_literal: true

class LabProjectsController < ProjectsController
  def show
    redirect_to lab_path(@project.lab)
  end
end
