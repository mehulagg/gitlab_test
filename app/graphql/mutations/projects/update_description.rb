# frozen_string_literal: true

module Mutations
  module Projects
    class UpdateDescription < Base
      graphql_name 'ProjectsUpdateDecription'

      argument :full_path
    end
  end
end