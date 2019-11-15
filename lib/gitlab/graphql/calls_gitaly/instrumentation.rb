# frozen_string_literal: true

module Gitlab
  module Graphql
    module CallsGitaly
      class Instrumentation

        MINIMUM_GITALY_CALL_COMPLEXITY = (::GitlabSchema::DEFAULT_FIELD_COMPLEXITY + ::GitlabSchema::GITALY_CALL_COMPLEXITY).freeze

        # Check if any `calls_gitaly: true` declarations need to be added.
        # Do nothing if a complexity was provided
        def instrument(_type, field)
          type_object = field.metadata[:type_class]
          return field unless type_object.respond_to?(:field_complexity)
          return field unless type_object.field_complexity.to_i < MINIMUM_GITALY_CALL_COMPLEXITY

          old_resolver_proc = field.resolve_proc

          gitaly_wrapped_resolve = -> (typed_object, args, ctx) do
            previous_gitaly_call_count = Gitlab::GitalyClient.get_request_count
            result = old_resolver_proc.call(typed_object, args, ctx)
            current_gitaly_call_count = Gitlab::GitalyClient.get_request_count
            calls_gitaly_check(type_object, current_gitaly_call_count - previous_gitaly_call_count)
            result
          end

          field.redefine do
            resolve(gitaly_wrapped_resolve)
          end
        end

        def calls_gitaly_check(type_object, calls)
          return if calls < 1

          # Will inform you if there needs to be `calls_gitaly: true` as a kwarg in the field declaration
          # if there is at least 1 Gitaly call involved with the field resolution.
          error = RuntimeError.new("Gitaly is called for field '#{type_object.name}' on #{type_object.owner.try(:name)} - please either specify a complexity or add `calls_gitaly: true` to the field declaration")
          Gitlab::Sentry.track_exception(error)
        end
      end
    end
  end
end
