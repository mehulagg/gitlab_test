# frozen_string_literal: true

module Types
  class BaseEnum < GraphQL::Schema::Enum
    extend GitlabStyleDeprecations

    LOWERCASE_VALUE_ERROR = 'GitLab enum values must be uppercase. ' \
                            'See https://docs.gitlab.com/ee/development/api_graphql_styleguide.html#enums' \

    class << self
      def value(*args, **kwargs, &block)
        value = args[0]

        raise ArgumentError, LOWERCASE_VALUE_ERROR if value.match(/\p{Lower}/) && !kwargs[:deprecated]

        enum[value.downcase] = kwargs[:value] || value

        kwargs = gitlab_deprecation(kwargs)

        super(*args, **kwargs, &block)
      end

      # Returns an indifferent access hash with the key being the downcased name of the attribute
      # and the value being the Ruby value (either the explicit `value` passed or the same as the value attr).
      def enum
        @enum_values ||= {}.with_indifferent_access
      end
    end
  end
end
