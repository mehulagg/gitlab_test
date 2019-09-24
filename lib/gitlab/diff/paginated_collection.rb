# frozen_string_literal: true

module Gitlab
  module Diff
    class PaginatedCollection < SimpleDelegator
      # diff_collection - A Gitlab::Git::DiffCollection object
      def initialize(diff_collection, pagination_data = nil)
        @diff_collection = super(diff_collection)
        @pagination_data = pagination_data
      end

      def total_pages
        @pagination_data.fetch(:total_pages)
      end

      def next_page
        @pagination_data.fetch(:next_page)
      end

      def current_page
        @pagination_data.fetch(:current_page)
      end
    end
  end
end
