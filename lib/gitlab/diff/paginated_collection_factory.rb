# frozen_string_literal: true

module Gitlab
  module Diff
    class PaginatedCollectionFactory
      def initialize(batch_page, batch_size)
        @batch_page, @batch_size = batch_page, batch_size
      end

      def fabricate(collection)
        # All kinds of logic for checking if it's a relation can happen here:
        paginated_collection = collection.page(@batch_page).per(@batch_size)

        pagination_data = {
          current_page: paginated_collection.current_page,
          next_page: paginated_collection.next_page,
          total_pages: paginated_collection.total_pages
        }

        diff_collection = Gitlab::Git::DiffCollection
          .new(paginated_collection.map(&:to_hash), limits: false)

        Gitlab::Diff::PaginatedCollection.new(diff_collection, pagination_data)
      end
    end
  end
end
