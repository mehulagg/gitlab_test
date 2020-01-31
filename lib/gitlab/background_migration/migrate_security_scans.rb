# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # rubocop: disable Style/Documentation
    class MigrateSecurityScans
      def perform(*job_artifact_ids)
      end
    end
  end
end

Gitlab::BackgroundMigration::MigrateSecurityScans.prepend_if_ee('EE::Gitlab::BackgroundMigration::MigrateSecurityScans')
