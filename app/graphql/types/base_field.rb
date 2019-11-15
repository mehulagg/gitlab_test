# frozen_string_literal: true

module Types
  class BaseField < GraphQL::Schema::Field
    prepend Gitlab::Graphql::Authorize

    attr_reader :field_complexity

    def initialize(*args, **kwargs, &block)
      @field_complexity = kwargs[:complexity] = determine_complexity(kwargs)

      super(*args, **kwargs, &block)
    end

    private

    def determine_complexity(kwargs)
      # kwargs[:complexity] will be either:
      # - The complexity from the field's resolver class, if this field has one.
      #   This will be the hard-coded default of 1 unless the resolver has specified
      #   a complexity
      # - The complexity defined on the field itself with the `complexity` keyword argument
      # - nil
      check_field_and_resolver_complexity_are_equivalent!(kwargs)

      complexity = kwargs[:complexity] || ::GitlabSchema::DEFAULT_FIELD_COMPLEXITY
      # Increment if field is marked with `calls_gitaly`
      complexity += ::GitlabSchema::GITALY_CALL_COMPLEXITY if !!kwargs.delete(:calls_gitaly)
      complexity
    end

    # TODO better name
    # TODO explain this.
    # This is performing a sanity check that the field doesn't override
    # the complexity on a resolver.
    # Raise if the field has overridden the resolver's complexity
    def check_field_and_resolver_complexity_are_equivalent!(kwargs)
      resolver_complexity = kwargs[:resolver_class]&.complexity
      return unless resolver_complexity

      if resolver_complexity != kwargs[:complexity]
        raise Gitlab::Graphql::Errors::ArgumentError, error_message(kwargs, resolver_complexity)
      end
    end

    def error_message(kwargs, resolver_complexity)
      error = "Field :#{kwargs[:name]} cannot define a complexity of #{kwargs[:complexity]}, " \
              "as its resolver #{kwargs[:resolver_class].name} already has a complexity of #{resolver_complexity}"
      if resolver_complexity == 1
        error += ". This may be the default resolver complexity. " \
                 "Perhaps you should fix this error by defining a complexity of #{kwargs[:complexity]} " \
                 "on #{kwargs[:resolver_class].name}"
      end

      error
    end
  end
end
