# frozen_string_literal: true

module EE
  module Ci
    module Queueing
      module FindMatchingJobs
        extend ActiveSupport::Concern

        def builds_for_shared_runner
          return super unless shared_runner_build_limits_feature_enabled?
  
          enforce_minutes_based_on_cost_factors(super)
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def enforce_minutes_based_on_cost_factors(relation)
          visibility_relation = ::Ci::Build.where(
            projects: { visibility_level: params.visibility_levels_without_minutes_quota })

          enforce_limits_relation = ::Ci::Build.where('EXISTS (?)', builds_check_limit)

          relation.merge(visibility_relation.or(enforce_limits_relation))
        end
        # rubocop: enable CodeReuse/ActiveRecord

        # rubocop: disable CodeReuse/ActiveRecord
        def builds_check_limit
          all_namespaces
            .joins('LEFT JOIN namespace_statistics ON namespace_statistics.namespace_id = namespaces.id')
            .where('COALESCE(namespaces.shared_runners_minutes_limit, ?, 0) = 0 OR ' \
                   'COALESCE(namespace_statistics.shared_runners_seconds, 0) < ' \
                   'COALESCE('\
                     '(namespaces.shared_runners_minutes_limit + COALESCE(namespaces.extra_shared_runners_minutes_limit, 0)), ' \
                     '(? + COALESCE(namespaces.extra_shared_runners_minutes_limit, 0)), ' \
                    '0) * 60',
                  application_shared_runners_minutes, application_shared_runners_minutes)
            .select('1')
        end
        # rubocop: enable CodeReuse/ActiveRecord

        # rubocop: disable CodeReuse/ActiveRecord
        def all_namespaces
          namespaces = ::Namespace.reorder(nil).where('namespaces.id = projects.namespace_id')
          ::Gitlab::ObjectHierarchy.new(namespaces).roots
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def application_shared_runners_minutes
          ::Gitlab::CurrentSettings.shared_runners_minutes
        end

        def shared_runner_build_limits_feature_enabled?
          ENV['DISABLE_SHARED_RUNNER_BUILD_MINUTES_LIMIT'].to_s != 'true'
        end
      end
    end
  end
end
