# frozen_string_literal: true

module Gitlab
  module Graphql
    # Wraps the field resolution to count Gitaly calls before and after.
    # Raises an error if the field calls Gitaly but hadn't declared such.

    # I wonder if we could replace this with
    # named complexities
    #
    # complexity: :gitaly_simple
    # complexity: :gitaly_complex
    # complexity: :postgres_simple
    # etc
    # with symbols map to complexity scores
    module CallsGitaly
      extend ActiveSupport::Concern

      def self.use(schema_definition)
        schema_definition.instrument(:field, Gitlab::Graphql::CallsGitaly::Instrumentation.new, after_built_ins: true)
      end
    end
  end
end
