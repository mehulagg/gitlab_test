# frozen_string_literal: true

class LabGroupsController < GroupsController
  def show
    redirect_to lab_path(@group.lab)
  end
end
