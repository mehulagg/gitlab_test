# frozen_string_literal: true

module Gitlab
  module Elastic
    class SnippetSearchResults < ::Gitlab::SnippetSearchResults
      extend ::Gitlab::Utils::Override

      override :formatted_count
      def formatted_count(scope)
        case scope
        when 'snippet_titles'
          snippet_titles_count.to_s
        when 'snippet_blobs'
          snippet_blobs_count.to_s
        else
          super
        end
      end

      def snippet_titles_count
        limited_snippet_titles_count
      end

      def snippet_blobs_count
        limited_snippet_blobs_count
      end

      private

      override :limited_snippet_titles_count
      def limited_snippet_titles_count
        strong_memoize(:limited_snippet_titles_count) do
          snippet_titles.total_count
        end
      end

      override :limited_snippet_blobs_count
      def limited_snippet_blobs_count
        strong_memoize(:limited_snippet_blobs_count) do
          snippet_blobs.total_count
        end
      end

      override :snippet_titles
      def snippet_titles(_ = {})
        Snippet.elastic_search(query, options: search_params)
      end

      override :snippet_blobs
      def snippet_blobs(_ = {})
        Snippet.elastic_search_code(query, options: search_params)
      end

      override :paginated_objects
      def paginated_objects(relation, page)
        super.records
      end

      def search_params
        { user: current_user }
      end
    end
  end
end
