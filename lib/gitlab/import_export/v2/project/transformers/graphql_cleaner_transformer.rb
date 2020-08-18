# frozen_string_literal: true

module Gitlab::ImportExport::V2::Project::Transformers
  class GraphqlCleanerTransformer
    def self.transform(data)
      result = data['data']['project'].dup

      key = result.keys.first

      result = clean_edges(result, key)

      if result[key].is_a?(Array)
        result.each do |key, value|
          if value.is_a?(Hash) && value.has_key?('edges')
            result[key] = clean_edges(value, key)
          end
        end
      end

      result
    end

    def self.clean_edges(data, key)
      data[key] = data[key]['edges']

      data[key] = data[key].map { |i| i['node'] }

      data
    end
  end
end
