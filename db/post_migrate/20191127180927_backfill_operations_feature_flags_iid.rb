# frozen_string_literal: true

class BackfillOperationsFeatureFlagsIid < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  class OperationsFeatureFlag < ActiveRecord::Base
    include AtomicInternalId
    self.table_name = 'operations_feature_flags'
    self.inheritance_column = :_type_disabled

    belongs_to :project

    has_internal_id :iid, scope: :project, init: ->(s) { s&.project&.operations_feature_flags&.maximum(:iid) }
  end

  ###
  # This should update about 500 rows on gitlab.com
  # https://gitlab.com/gitlab-org/gitlab/merge_requests/20871#note_251723686
  #
  # It takes a few seconds to run locally with 500 rows
  # https://gitlab.com/gitlab-org/gitlab/merge_requests/20871#note_254891446
  ###
  def up
    OperationsFeatureFlag.where(iid: nil).find_each do |flag|
      flag.ensure_project_iid!
      flag.save
    end
  end

  def down
  end
end
