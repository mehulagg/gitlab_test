# frozen_string_literal: true

module Elastic
  module Latest
    class MilestoneClassProxy < ApplicationClassProxy
      def elastic_search(query, options: {})
        options[:in] = %w(title^2 description)

        query_hash = QueryFactory.query_context(:milestone, :match) { basic_query_hash(options[:in], query) }
        query_hash = QueryFactory.query_context(:milestone, :related) { project_ids_filter(query_hash, options) }

        search(query_hash, options)
      end
    end
  end
end
