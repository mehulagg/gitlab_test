# frozen_string_literal: true

module Boards
  class ApplicationController < ::ApplicationController
    respond_to :json

    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

    set_current_tenant_through_filter
    before_action :set_namespace_as_tenant

    def set_namespace_as_tenant
      if board_parent.nil? || board_parent.root_ancestor.nil?
        logger.warn "Unable to set partition key in because the ancestor chain was nil"
      else
        set_current_tenant(board_parent.root_ancestor.path)
      end
    end

    private

    def board
      @board ||= Board.find(params[:board_id])
    end

    def board_parent
      @board_parent ||= board.resource_parent
    end

    def record_not_found(exception)
      render json: { error: exception.message }, status: :not_found
    end
  end
end
