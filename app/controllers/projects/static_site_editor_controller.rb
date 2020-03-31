# frozen_string_literal: true

class Projects::StaticSiteEditorController < Projects::ApplicationController
  include ExtractsPath
  layout 'fullscreen'

  prepend_before_action :authenticate_user!, only: [:edit]
  before_action :assign_path_and_ref, only: [:edit]

  def edit
    render_404 unless can_collaborate_with_project?(project, ref: @ref)

    if static_site_editor.valid?
      @data = static_site_editor.data
    else
      @errors = static_site_editor.errors
    end
  end

  private

  def assign_path_and_ref
    @id = params[:id]
    @ref, @path = extract_ref(@id)
  rescue InvalidPathError
    render_404
  end

  # TODO: I'm not happy with naming
  # The idea is to extract validations from the controller level and have them grouped in one place
  def static_site_editor
    @static_site_editor ||= StaticSiteEditor.new(@repository, @ref, @path)
  end
end
