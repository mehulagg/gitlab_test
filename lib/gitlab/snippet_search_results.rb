# frozen_string_literal: true

module Gitlab
  class SnippetSearchResults < SearchResults
    include SnippetsHelper
    include Gitlab::Utils::StrongMemoize

    attr_reader :current_user

    def initialize(current_user, query)
      @current_user = current_user
      @query = query
    end

    def objects(scope, page = nil)
      case scope
      when 'snippet_titles'
        paginated_objects(snippet_titles, page)
      when 'snippet_blobs'
        paginated_objects(snippet_blobs, page)
      else
        super(scope, nil, false)
      end
    end

    def formatted_count(scope)
      case scope
      when 'snippet_titles'
        formatted_limited_count(limited_snippet_titles_count)
      when 'snippet_blobs'
        formatted_limited_count(limited_snippet_blobs_count)
      else
        super
      end
    end

    def limited_snippet_titles_count
      strong_memoize(:limited_snippet_titles_count) do
        partial_count(:snippet_titles)
      end
    end

    def limited_snippet_blobs_count
      strong_memoize(:limited_snippet_blobs_count) do
        partial_count(:snippet_blobs)
      end
    end

    private

    # rubocop: disable CodeReuse/ActiveRecord
    def snippets(finder_params = {})
      SnippetsFinder.new(current_user, finder_params)
        .execute
        .includes(:author)
        .reorder(updated_at: :desc)
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def snippet_titles(finder_params = {})
      snippets(finder_params).search(query)
    end

    def snippet_blobs(finder_params = {})
      snippets(finder_params).search_code(query)
    end

    def default_scope
      'snippet_blobs'
    end

    # rubocop:disable GitlabSecurity/PublicSend
    def partial_count(method_sym)
      sum = limited_count(self.send(method_sym, personal_only: true))
      sum < count_limit ? limited_count(self.send(method_sym)) : sum
    end
    # rubocop:enable GitlabSecurity/PublicSend

    def paginated_objects(relation, page)
      relation.page(page).per(per_page)
    end
  end
end
