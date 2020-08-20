# frozen_string_literal: true

module Gitlab::ImportExport::V2::Project
  class IssuesPipeline
    def self.execute(source: 'georgekoltsov-group/testing-events', target: Project.last)
      # Extract
      data = Extractors::IssuesExtractor.new.extract(project: source)

      # Transform
      data = data
        .then { |data| Transformers::Base::GraphqlCleanerTransformer.transform(data) }
        .then { |data| Transformers::Base::UnderscorifyKeysTransformer.transform(data) }
        .then { |data| Transformers::Base::UserReferenceTransformer.transform(data) }

      # Load
      Loaders::IssueLoader.load(data, target)
    end
  end
end
