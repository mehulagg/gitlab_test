# frozen_string_literal: true

module Ci
  module Queueing
    class FindMatchingJobs
      attr_reader :params

      def initialize(params)
        @params = params
      end

      def execute
        builds = builds_for_runner_type

        if params.only_ref_protected
          builds = builds.ref_protected
        end

        # pick builds that does not have other tags than runner's one
        builds = builds.matches_tag_ids(
          ActsAsTaggableOn::Tag.where(name: params.tag_names).select(:id)
        )

        # pick builds that have at least one tag
        unless params.run_untagged
          builds = builds.with_any_tags
        end

        builds
      end

      private

      def builds_for_runner_type
        # TODO: This should be symbol
        case params.runner_type.to_sym
        when :instance_type
          builds_for_shared_runner
        when :group_type
          builds_for_group_runner
        when :project_type
          builds_for_project_runner
        else
          raise ArgumentError, "invalid params.runner_type: #{params.runner_type}"
        end
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def builds_for_shared_runner
        new_builds.
          # don't run projects which have not enabled shared runners and builds
          joins(:project).where(projects: { shared_runners_enabled: true, pending_delete: false })
          .joins('LEFT JOIN project_features ON ci_builds.project_id = project_features.project_id')
          .where('project_features.builds_access_level IS NULL or project_features.builds_access_level > 0').

        # Implement fair scheduling
        # this returns builds that are ordered by number of running builds
        # we prefer projects that don't use shared runners at all
        joins("LEFT JOIN (#{running_builds_for_shared_runners.to_sql}) AS project_builds ON ci_builds.project_id=project_builds.project_id")
          .order(Arel.sql('COALESCE(project_builds.running_builds, 0) ASC'), 'ci_builds.id ASC')
      end
      # rubocop: enable CodeReuse/ActiveRecord

      # rubocop: disable CodeReuse/ActiveRecord
      def builds_for_project_runner
        projects = ::Project.where(id: params.project_ids)
          .with_builds_enabled
          .without_deleted

        new_builds.where(project: projects).order('id ASC')
      end
      # rubocop: enable CodeReuse/ActiveRecord

      # rubocop: disable CodeReuse/ActiveRecord
      def builds_for_group_runner
        # Workaround for weird Rails bug, that makes `runner.groups.to_sql` to return `runner_id = NULL`
        groups = ::Group.where(id: params.group_ids)

        hierarchy_groups = Gitlab::ObjectHierarchy.new(groups).base_and_descendants
        projects = Project.where(namespace_id: hierarchy_groups)
          .with_group_runners_enabled
          .with_builds_enabled
          .without_deleted
        new_builds.where(project: projects).order('id ASC')
      end
      # rubocop: enable CodeReuse/ActiveRecord

      # rubocop: disable CodeReuse/ActiveRecord
      def running_builds_for_shared_runners
        Ci::Build.running.where(runner: Ci::Runner.instance_type)
          .group(:project_id).select(:project_id, 'count(*) AS running_builds')
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def new_builds
        Ci::Build.pending.unstarted
      end
    end
  end
end
