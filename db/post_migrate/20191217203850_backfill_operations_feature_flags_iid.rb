# frozen_string_literal: true

class BackfillOperationsFeatureFlagsIid < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  ###
  # This should update about 500 rows on gitlab.com
  # https://gitlab.com/gitlab-org/gitlab/merge_requests/20871#note_251723686
  #
  # Execution time is predicted to take some seconds based on experiments
  # https://gitlab.com/gitlab-org/gitlab/merge_requests/20871#note_254891446
  #
  # https://gitlab.com/gitlab-org/gitlab/merge_requests/20871#note_255449819
  ###
  def up
    sql = <<-END
      UPDATE operations_feature_flags
      SET iid = feature_flags_with_calculated_iid.iid_num
      FROM (
        SELECT id, ROW_NUMBER() OVER (PARTITION BY project_id ORDER BY iid, id ASC NULLS LAST) AS iid_num FROM operations_feature_flags
      ) AS feature_flags_with_calculated_iid
      WHERE operations_feature_flags.id = feature_flags_with_calculated_iid.id
    END

    execute(sql)

    delete_internal_ids_sql = <<-END
      DELETE FROM internal_ids WHERE project_id IN (SELECT DISTINCT(project_id) FROM operations_feature_flags) AND usage = 6
    END

    execute(delete_internal_ids_sql)
  end

  def down
    # no-op
  end
end
