# frozen_string_literal: true

class Projects::StaticSiteEditorController < Projects::ApplicationController
  include ExtractsPath
  include CreatesCommit

  layout 'fullscreen'

  prepend_before_action :authenticate_user!, only: [:show]
  before_action :assign_ref_and_path, only: [:show]
  before_action :authorize_edit_tree!, only: [:show]
  before_action do
    push_frontend_feature_flag(:sse_image_uploads)
  end

  def show
    config = Gitlab::StaticSiteEditor::Config::CombinedConfig.new(
      @repository,
      @ref,
      @path,
      params[:return_url]
    )
    @data = config.data
  end

  private

  def assign_ref_and_path
    @ref, @path = extract_ref(params[:id])

    render_404 if @ref.blank? || @path.blank?
  end
end
