# frozen_string_literal: true

module Gitlab::ImportExport::V2::Project::Transformers::Issues
  class IssuesTransformer
    def self.transform(data)
      data.deep_transform_keys do |key|
        key.underscore
      end
    end
  end
end
