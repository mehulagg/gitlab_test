# frozen_string_literal: true

module Elastic
  module Latest
    class MergeRequestClassProxy < ApplicationClassProxy
      include StateFilter

      def elastic_search(query, options: {})
        query_hash =
          if query =~ /\!(\d+)\z/
            iid_query_hash(Regexp.last_match(1))
          else
            fields = %w(title^2 description)

            # We can only allow searching the iid field if the query is
            # just a number, otherwise Elasticsearch will error since this
            # field is type integer.
            fields << "iid^3" if query =~ /\A\d+\z/

            basic_query_hash(fields, query)
          end

        options[:features] = 'merge_requests'
        QueryFactory.query_context(:merge_request) do
          query_hash = QueryFactory.query_context(:authorized) { project_ids_filter(query_hash, options) }
          query_hash = QueryFactory.query_context(:match) { state_filter(query_hash, options) }
        end

        search(query_hash, options)
      end
    end
  end
end
