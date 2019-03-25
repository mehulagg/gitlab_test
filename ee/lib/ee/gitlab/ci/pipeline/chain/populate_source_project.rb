# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Pipeline
        module Chain
          module PopulateSourceProject
            extend ::Gitlab::Utils::Override

            include ::Gitlab::Ci::Pipeline::Chain::Helpers
            include ::Gitlab::Allowable

            override :perform!
            def perform!
              return unless pipeline.default_branch? && cross_project_pipelines_enabled?

              pipeline.stages.map(&:bridges).flatten.each do |bridge|
                next unless bridge.instance_of?(::Ci::Bridges::UpstreamBridge)

                if (upstream_project = ::Project.find_by_full_path(bridge.upstream_project_path))
                  if can_create_cross_pipeline?(upstream_project)
                    # rubocop:disable CodeReuse/ActiveRecord
                    source = ::Ci::Sources::Project.find_or_initialize_by(project: project, source_project: upstream_project)
                    # rubocop:enable CodeReuse/ActiveRecord
                    pipeline.source_project = source
                  else
                    return error('User does not have enough permissions to observe the upstream project')
                  end
                else
                  bridge.status = "failed"
                  bridge.failure_reason = :upstream_bridge_project_not_found
                end
              end
            end

            override :break?
            def break?
              pipeline.errors.any?
            end

            private

            def cross_project_pipelines_enabled?
              project.feature_available?(:cross_project_pipelines)
            end

            def can_create_cross_pipeline?(upstream_project)
              can?(current_user, :read_project, upstream_project) &&
                can?(current_user, :create_pipeline, project)
            end
          end
        end
      end
    end
  end
end
