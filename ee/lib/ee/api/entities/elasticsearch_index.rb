# frozen_string_literal: true

module EE
  module API
    module Entities
      class ElasticsearchIndex < Grape::Entity
        expose :id
        expose :name
        expose :friendly_name
        expose :version

        expose :shards
        expose :replicas
        expose :urls do |index|
          index.urls.join(', ')
        end

        expose :aws
        expose :aws_region
        expose :aws_access_key
        expose :aws_secret_access_key

        expose :active_search_source do |index, options|
          index.id == options[:current_settings].elasticsearch_read_index_id
        end
      end
    end
  end
end
