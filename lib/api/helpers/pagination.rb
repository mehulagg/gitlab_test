# frozen_string_literal: true

module API
  module Helpers
    module Pagination
      extend ActiveSupport::Concern

      PAGINATION_OFFSET_BUCKETS = [20, 100, 1000, 10000, 50000, 100000, 1000000].freeze

      def paginate(relation)
        pagination_track_metrics if Feature.enabled?(:pagination_offset_metrics)

        ::Gitlab::Pagination::OffsetPagination.new(self).paginate(relation)
      end

      private

      def pagination_track_metrics
        labels = {
          path: route&.path,
          method: route&.request_method,
          version: route&.version
        }
        offset = params[:page].to_i * params[:per_page].to_i

        self.class.pagination_metrics_offset_histogram.observe(labels, offset)
      end

      class_methods do
        def pagination_metrics_offset_histogram
          @pagination_metrics_offset_histogram ||= Gitlab::Metrics.histogram(:api_pagination_offsets, 'Offsets for default pagination strategy', {}, OFFSET_BUCKETS)
        end
      end
    end
  end
end
