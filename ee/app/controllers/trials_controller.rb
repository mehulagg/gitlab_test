# frozen_string_literal: true

class TrialsController < ApplicationController
  before_action :set_redirect_url, only: [:new]

  private

  def set_redirect_url
    store_location_for(:user, root_url)
  end
end
