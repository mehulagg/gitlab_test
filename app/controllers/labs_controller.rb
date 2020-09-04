# frozen_string_literal: true

class LabsController < ApplicationController
  before_action :lab, only: [:show]

  def show
  end

  private

  def lab
    @lab = Lab.find(params[:id])
  end
end
