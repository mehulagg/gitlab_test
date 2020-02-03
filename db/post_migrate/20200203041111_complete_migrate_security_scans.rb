# frozen_string_literal: true

class CompleteMigrateSecurityScans < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  BATCH_SIZE = 1000
  SECURITY_FILE_TYPES = [5, 6, 7, 8].freeze

  disable_ddl_transaction!

  class JobArtifact < ActiveRecord::Base
    self.table_name = 'ci_job_artifacts'

    belongs_to :build, class_name: 'Build'
  end

  class Build < ActiveRecord::Base
    include ::EachBatch

    self.table_name = 'ci_builds'
    self.inheritance_column = :_type_disabled

    has_many :job_artifacts, class_name: 'JobArtifact', foreign_key: 'job_id'
    has_many :security_scans, class_name: 'SecurityScan', foreign_key: 'build_id'
  end

  class SecurityScan < ActiveRecord::Base
    self.table_name = 'security_scans'

    belongs_to :build, class_name: 'Build'
  end

  def up
    Gitlab::BackgroundMigration.steal('MigrateSecurityScans')

    Build
      .joins(:job_artifacts)
      .left_outer_joins(:security_scans)
      .select('ci_job_artifacts.id')
      .where('ci_job_artifacts.file_type': SECURITY_FILE_TYPES)
      .where('security_scans.id IS NULL')
      .each_batch(of: BATCH_SIZE) do |batch|
      artifact_ids = batch.pluck(:id)
      Gitlab::BackgroundMigration::MigrateSecurityScans.new.perform(*artifact_ids)
    end
  end

  def down
    # intentionally blank
  end
end
