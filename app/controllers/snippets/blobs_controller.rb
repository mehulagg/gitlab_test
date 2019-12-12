# frozen_string_literal: true

class Snippets::BlobsController < ApplicationController
  include RendersBlob
  include SnippetsActions

  before_action :snippet, only: [:show, :raw]
  before_action :authorize_read_snippet!, only: [:show, :raw]

  skip_before_action :authenticate_user!, only: [:show, :raw]

  def show
    respond_to do |format|
      format.html do
        head :not_found
      end

      format.json do
        # TODO review this
        conditionally_expand_blob(blob)

        render_blob_json(blob)
      end

      format.js do
        if @snippet.embeddable?
          render 'shared/snippets/show'
        else
          head :not_found
        end
      end
    end
  end

  private

  def authorize_read_snippet!
    return if can?(current_user, :read_personal_snippet, @snippet)

    if current_user
      render_404
    else
      authenticate_user!
    end
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def snippet
    @snippet ||= PersonalSnippet.inc_relations_for_view.find_by(id: params[:snippet_id])
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def blob
    @blob ||= snippet.repository.blob_at(root_ref, params[:id])
  end

  def root_ref
    @root_ref ||= @snippet.repository.root_ref
  end
end
