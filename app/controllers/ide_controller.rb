# frozen_string_literal: true

class IdeController < ApplicationController
  layout 'fullscreen'

  def index
    @collapsible_header = true
    Gitlab::UsageDataCounters::WebIdeCounter.increment_views_count
  end
end

IdeController.prepend_if_ee('EE::IdeController')
