# frozen_string_literal: true

module Gitlab
  module Elasticsearch
    class Logs
      # How many log lines to fetch in a query
      LOGS_LIMIT = 500

      def initialize(client)
        @client = client
      end

      def pod_logs(namespace = nil, pod_name = nil, container_name = nil)
        matches = []

        # A cluster can contain multiple namespaces.
        # By default we return logs from every namespace
        unless namespace.nil?
          matches << {
            match_phrase: {
              "kubernetes.namespace" => {
                query: namespace
              }
            }
          }
        end

        # A namespace can contain multiple pods.
        # By default we return logs from every pod
        unless pod_name.nil?
          matches << {
            match_phrase: {
              "kubernetes.pod.name" => {
                query: pod_name
              }
            }
          }
        end

        # A pod can contain multiple containers.
        # By default we return logs from every container
        unless container_name.nil?
          matches << {
            match_phrase: {
              "kubernetes.container.name" => {
                query: container_name
              }
            }
          }
        end

        body = {
          # reverse order so we can query N-most recent records
          sort: [
            { "@timestamp": { order: :desc } },
            { "offset": { order: :desc } }
          ],
          # only return the message field in the response
          _source: ["message"],
          # fixed limit for now, we should support paginated queries
          size: ::Gitlab::Elasticsearch::Logs::LOGS_LIMIT
        }

        if matches.any?
          body[:query] = {
            bool: {
              must: matches
            }
          }
        end

        response = @client.search body: body
        result = response.fetch("hits", {}).fetch("hits", []).map { |h| h["_source"]["message"] }

        # we queried for the N-most recent records but we want them ordered oldest to newest
        result.reverse
      end
    end
  end
end
