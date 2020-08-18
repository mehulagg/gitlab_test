# frozen_string_literal: true

module Gitlab::ImportExport::V2::Project::Transformers
  class GraphqlCleanerTransformer
    def self.transform(data)
      relation = data['data']['project'].keys.first
      result = {}

      result[relation] = clean_edges_and_nodes(data['data']['project'][relation])

      if result[relation].is_a?(Array)
        result[relation] = result[relation].map do |relation_item|
          relation_item.each_with_object({}) do |(key, value), result|
            if value.is_a?(Hash) && value.has_key?('edges')
              result[key] = clean_edges_and_nodes(value)
            else
              result[key] = value
            end
          end
        end
      end

      result
    end

    def self.clean_edges_and_nodes(data)
      data['edges'].map { |i| i['node'] }
    end
  end
end
