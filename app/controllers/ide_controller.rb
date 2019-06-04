# frozen_string_literal: true

class IdeController < ApplicationController
  layout 'fullscreen'

  before_action do
    push_frontend_feature_flag(:build_service_proxy)
  end

  def index
  end
end
