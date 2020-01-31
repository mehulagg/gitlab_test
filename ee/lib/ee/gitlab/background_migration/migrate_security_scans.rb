# frozen_string_literal: true

# rubocop: disable Gitlab/ModuleWithInstanceVariables
module EE
  module Gitlab
    module BackgroundMigration
      module MigrateSecurityScans
        extend ::Gitlab::Utils::Override

        override :perform
        def perform(*job_artifact_ids)
          return if job_artifact_ids.empty?

          execute <<~SQL
            /* Map Ci::JobArtifact file_type to Security::Scan scan_type */
            WITH scan_types (job_artifact_type, scan_type) AS (
              SELECT job_artifact_type, scan_type
              FROM ( VALUES (5, 1),
                            (6, 2),
                            (7, 3),
                            (8, 4))
              AS scan_types (job_artifact_type, scan_type) )
            INSERT INTO security_scans (created_at, updated_at, build_id, pipeline_id, scan_type)
            SELECT NOW(), NOW(), ci_builds.id, ci_builds.commit_id, scan_types.scan_type
            FROM ci_job_artifacts
            INNER JOIN ci_builds ON ci_builds.id = ci_job_artifacts.job_id
            INNER JOIN scan_types ON ci_job_artifacts.file_type = scan_types.job_artifact_type
            /* Left Join to ensure we are only inserting records that don't already exist */
            LEFT OUTER JOIN security_scans ON ci_builds.id = security_scans.build_id
                                           AND ci_builds.commit_id = security_scans.pipeline_id
            WHERE ci_job_artifacts.id IN (#{job_artifact_ids.join(',')})
            AND security_scans.id IS NULL;
          SQL
        end

        def execute(sql)
          @connection ||= ::ActiveRecord::Base.connection
          @connection.execute(sql)
        end
      end
    end
  end
end
