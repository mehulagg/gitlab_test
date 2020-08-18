# frozen_string_literal: true

module Gitlab::ImportExport::V2::Project
  class IssuesPipeline
    def self.execute(source: 'georgekoltsov/alfred-gitlab', target: Project.last)
      # Extract
      data = Extractors::IssuesExtractor.new.extract(project: source)

      # Transformer
      data = data
        .then { |data| Transformers::GraphqlCleanerTransformer.transform(data) }
        .then { |data| Transformers::UnderscorifyKeysTransformer.transform(data) }

      # Load
      Loaders::IssueLoader.load(data, target)
    end
  end
end
