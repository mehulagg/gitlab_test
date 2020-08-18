# frozen_string_literal: true

module Gitlab::ImportExport::V2::Project
  class IssuesPipeline
    def self.execute(source: 'georgekoltsov/alfred-gitlab', target: Project.last)
      # Extractor
      data = Extractors::IssuesExtractor.new.extract(project: source).original_hash

      # Transformers
      data = Transformers::GraphqlCleanerTransformer.transform(data)
      data = Transformers::UnderscorifyKeysTransformer.transform(data)

      # Loader
      data['issues'].each do |issue|
        target.issues.create!(issue)
      end
    end
  end
end
