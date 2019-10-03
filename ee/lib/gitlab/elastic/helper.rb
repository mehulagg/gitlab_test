# frozen_string_literal: true

module Gitlab
  module Elastic
    module Helper
      def self.create_empty_index(index)
        config = ::Elastic.const_get(index.version, false)::Config

        mappings = config.mappings.to_hash
        settings = config.settings.to_hash.deep_merge(
          index: {
            number_of_shards: index.shards,
            number_of_replicas: index.replicas
          }
        )

        client = index.client

        # ES5.6 needs a setting enabled to support JOIN datatypes that ES6 does not support...
        if Gitlab::VersionInfo.parse(client.info['version']['number']) < Gitlab::VersionInfo.new(6)
          settings.deep_merge!(
            index: { mapping: { single_type: true } }
          )
        end

        if client.indices.exists? index: index.name # rubocop: disable CodeReuse/ActiveRecord
          client.indices.delete index: index.name
        end

        client.indices.create(
          index: index.name,
          body: {
            mappings: mappings.to_hash,
            settings: settings.to_hash
          }
        )
      end

      def self.delete_index(index)
        index.client.indices.delete index: index.name
      end

      # Calls Elasticsearch refresh API to ensure data is searchable
      # immediately.
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-refresh.html
      def self.refresh_index
        # Go through a class proxy, so the call gets forwarded to all indices
        Project.__elasticsearch__.refresh_index!
      end

      def self.index_size(index)
        index.client.indices.stats['indices'][index.name]['total']
      end
    end
  end
end
