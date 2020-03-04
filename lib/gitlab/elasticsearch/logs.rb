# frozen_string_literal: true

module Gitlab
  module Elasticsearch
    class Logs
      # How many log lines to fetch in a query
      LOGS_LIMIT = 500

      def initialize(client)
        @client = client
      end

      def pod_logs(namespace, pod_name, container_name: nil, search: nil, start_time: nil, end_time: nil, cursor: nil)
        query = { bool: { must: [] } }.tap do |q|
          filter_pod_name(q, pod_name)
          filter_namespace(q, namespace)
          filter_container_name(q, container_name)
          filter_search(q, search)
          filter_times(q, start_time, end_time)
        end

        body = build_body(query, cursor)
        response = @client.search body: body

        format_response(response)
      end

      private

      def build_body(query, cursor = nil)
        q = {
          query: query,
          # reverse order so we can query N-most recent records
          sort: [
            { "@timestamp": { order: :desc } },
            { "offset": { order: :desc } }
          ],
          # only return these fields in the response
          _source: ["@timestamp", "message"],
          # fixed limit for now, we should support paginated queries
          size: ::Gitlab::Elasticsearch::Logs::LOGS_LIMIT
        }

        unless cursor.nil?
          q[:search_after] = decode_cursor(cursor)
        end

        q
      end

      def filter_pod_name(query, pod_name)
        query[:bool][:must] << {
          match_phrase: {
            "kubernetes.pod.name" => {
              query: pod_name
            }
          }
        }
      end

      def filter_namespace(query, namespace)
        query[:bool][:must] << {
          match_phrase: {
            "kubernetes.namespace" => {
              query: namespace
            }
          }
        }
      end

      def filter_container_name(query, container_name)
        # A pod can contain multiple containers.
        # By default we return logs from every container
        return if container_name.nil?

        query[:bool][:must] << {
          match_phrase: {
            "kubernetes.container.name" => {
              query: container_name
            }
          }
        }
      end

      def filter_search(query, search)
        return if search.nil?

        query[:bool][:must] << {
          simple_query_string: {
            query: search,
            fields: [:message],
            default_operator: :and
          }
        }
      end

      def filter_times(query, start_time, end_time)
        return unless start_time || end_time

        time_range = { range: { :@timestamp => {} } }.tap do |tr|
          tr[:range][:@timestamp][:gte] = start_time if start_time
          tr[:range][:@timestamp][:lt] = end_time if end_time
        end

        query[:bool][:filter] = [time_range]
      end

      def format_response(response)
        results = response.fetch("hits", {}).fetch("hits", [])
        last_result = results.last
        results = results.map do |hit|
          {
            timestamp: hit["_source"]["@timestamp"],
            message: hit["_source"]["message"]
          }
        end

        # we queried for the N-most recent records but we want them ordered oldest to newest
        {
          logs: results.reverse,
          cursor: last_result.nil? ? nil : encode_cursor(last_result["sort"])
        }
      end

      # we want to hide the implementation details of the search_after parameter from the frontend
      # behind a single easily transmitted value
      def encode_cursor(obj)
        Base64.urlsafe_encode64(obj.to_json)
      end

      def decode_cursor(obj)
        cursor = JSON.parse(Base64.urlsafe_decode64(obj))

        if !cursor.instance_of?(Array) || cursor.length != 2 || !cursor.map {|i| i.instance_of?(Integer)}.reduce(:&)
          raise "invalid cursor format"
        end

        cursor

      rescue ArgumentError, JSON::ParserError => e # catches base64 decoder and json parser errors
        raise "invalid cursor #{e}"
      end
    end
  end
end
