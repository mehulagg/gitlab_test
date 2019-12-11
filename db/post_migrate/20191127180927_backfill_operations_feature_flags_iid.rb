# frozen_string_literal: true

class BackfillOperationsFeatureFlagsIid < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  # disable_ddl_transaction!

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
    execute('LOCK operations_feature_flags')

    execute('UPDATE operations_feature_flags SET iid = NULL')

    sql = <<-END
      UPDATE operations_feature_flags
      SET iid = feature_flags_with_calculated_iid.iid_num
      FROM (
        SELECT id, rank() OVER (PARTITION BY project_id ORDER BY id ASC) AS iid_num FROM operations_feature_flags
      ) AS feature_flags_with_calculated_iid
      WHERE operations_feature_flags.id = feature_flags_with_calculated_iid.id
    END

    execute(sql)

    # insert_sql = <<-END
    #   INSERT INTO internal_ids (project_id, usage, last_value)
    #   SELECT project_id, 6, MAX(iid)
    #   FROM operations_feature_flags
    #   GROUP BY project_id
    # END
    #
    # execute(insert_sql)
  end

  def down
    # no-op
  end
end
