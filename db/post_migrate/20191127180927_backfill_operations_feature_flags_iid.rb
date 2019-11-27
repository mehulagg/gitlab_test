# frozen_string_literal: true

class BackfillOperationsFeatureFlagsIid < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  class OperationsFeatureFlags < ActiveRecord::Base
    include EachBatch
    include AtomicInternalId

    belongs_to :project

    has_internal_id :iid, scope: :project, init: ->(s) { s&.project&.operations_feature_flags&.maximum(:iid) }
  end

  def up
    OperationsFeatureFlags.where(iid: nil).each_batch do |flags|
      flags.each do |flag|
        flag.ensure_project_iid!
        flag.save
      end
    end
  end

  def down
  end
end
