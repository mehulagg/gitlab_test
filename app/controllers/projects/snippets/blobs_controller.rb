# frozen_string_literal: true

module Projects
  module Snippets
    class BlobsController < Projects::ApplicationController
      include RendersBlob
      include SnippetsActions

      skip_before_action :repository
      before_action :snippet, only: [:show, :raw]

      before_action :authorize_read_project_snippet!, only: [:show, :raw]

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

      def authorize_read_project_snippet!
        return render_404 unless can?(current_user, :read_project_snippet, @snippet)
      end

      def authorize_update_snippet!
        return render_404 unless can?(current_user, :update_personal_snippet, @snippet)
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def snippet
        @snippet ||= ProjectSnippet.inc_relations_for_view.find_by(id: params[:snippet_id])
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def blob
        @blob ||= repository.blob_at(root_ref, params[:id])
      end

      def root_ref
        @root_ref ||= repository.root_ref
      end

      def repository
        @repository ||= snippet.repository
      end
    end
  end
end
