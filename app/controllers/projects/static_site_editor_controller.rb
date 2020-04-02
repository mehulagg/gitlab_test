# frozen_string_literal: true

class Projects::StaticSiteEditorController < Projects::ApplicationController
  layout 'fullscreen'

  prepend_before_action :authenticate_user!, only: [:edit]

  def edit
  end
end
