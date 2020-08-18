# frozen_string_literal: true

module Gitlab::ImportExport::V2::Project
  class IssuesPipeline
    def self.execute(source: 'georgekoltsov/alfred-gitlab', target: Project.last)
      Extractors::IssuesExtractor.new.extract(project: source)
        .then { |data| Transformers::GraphqlCleanerTransformer.transform(data) }
        .then { |data| Transformers::UnderscorifyKeysTransformer.transform(data) }
        .then { |data| Loaders::IssueLoader.load(data, target) }
    end
  end
end
