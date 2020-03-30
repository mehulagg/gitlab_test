# frozen_string_literal: true

class Projects::StaticSiteEditorController < Projects::ApplicationController
  include ExtractsPath
  layout 'fullscreen'

  prepend_before_action :authenticate_user!, only: [:edit]
  before_action :assign_path_and_ref, only: [:edit]

  def edit
    render_404 unless allow_access?
  end

  private

  def assign_path_and_ref
    @id = params[:id]
    @ref, @path = extract_ref(@id)
  rescue InvalidPathError
    render_404
  end

  def allow_access?
    can_collaborate_with_project?(project, ref: @ref) &&
      only_master_branch? &&
      markdown_extension? &&
      file_exists?
  end

  def only_master_branch?
    @ref == 'master'
  end

  def markdown_extension?
    File.extname(@path) == '.md'
  end

  def file_exists?
    @commit = @repository.commit(@ref)

    return render_404 unless @commit

    @repository.blob_at(@commit.id, @path).present?
  end
end
