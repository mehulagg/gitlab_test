# frozen_string_literal: true

module Gitlab
  module Graphql
    module Loaders
      class NamespaceStatisticsLoader
        def initialize(namespace_id)
          @namespace_id = namespace_id
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def find
          BatchLoader.for(namespace_id).batch do |ids, loader|
            results = Namespace.with_statistics.where(id: ids)

            results.each { |namespace| loader.call(namespace.id, namespace) }
          end
        end
        # rubocop: enable CodeReuse/ActiveRecord

        private

        attr_reader :namespace_id
      end
    end
  end
end
