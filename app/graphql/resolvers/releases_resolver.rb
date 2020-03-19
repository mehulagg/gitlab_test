# frozen_string_literal: true

module Resolvers
  class ReleasesResolver < BaseResolver
    type Types::ReleaseType, null: true

    argument :tag_name, GraphQL::STRING_TYPE,
            required: false,
            description: 'Find a release by tag name'

    alias_method :project, :object

    def resolve(tag_name: nil)
      ReleasesFinder.new(
        project,
        current_user,
        { tag: tag_name }
      ).execute
    end
  end
end
