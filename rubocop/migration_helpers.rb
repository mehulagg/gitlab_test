module RuboCop
  # Module containing helper methods for writing migration cops.
  module MigrationHelpers
    WHITELISTED_TABLES = %i[
      application_settings
      plan_limits
    ].freeze

    # Blacklisted due to its size
    BLACKLISTED_TABLES = %i[
      ci_build_trace_sections
      ci_builds
      ci_job_artifacts
      ci_pipelines
      ci_stages
      events
      issues
      merge_request_diff_commits
      merge_request_diff_files
      merge_request_diffs
      merge_requests
      namespaces
      notes
      projects
      project_ci_cd_settings
      routes
      services
      users
    ].freeze

    # Returns true if the given node originated from the db/migrate directory.
    def in_migration?(node)
      dirname(node).end_with?('db/migrate', 'db/geo/migrate') || in_post_deployment_migration?(node)
    end

    def in_post_deployment_migration?(node)
      dirname(node).end_with?('db/post_migrate', 'db/geo/post_migrate')
    end

    def version(node)
      File.basename(node.location.expression.source_buffer.name).split('_').first.to_i
    end

    private

    def dirname(node)
      File.dirname(node.location.expression.source_buffer.name)
    end
  end
end
