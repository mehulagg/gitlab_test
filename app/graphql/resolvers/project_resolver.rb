# frozen_string_literal: true

module Resolvers
  class ProjectResolver < BaseResolver
    prepend FullPathResolver

    type Types::ProjectType, null: true
    complexity 0 # Due to its old complexity_multipler. Is this right?

    def resolve(full_path:)
      model_by_full_path(Project, full_path)
    end
  end
end
