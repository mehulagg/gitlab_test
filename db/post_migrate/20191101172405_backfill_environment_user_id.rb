# frozen_string_literal: true

class BackfillEnvironmentUserId < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def up
    execute <<-SQL
      UPDATE environments
      SET user_id = subquery.user_id
      FROM
          (SELECT DISTINCT ON (environment_id) deployments.*
           FROM deployments
           ORDER BY environment_id, deployments.id) AS subquery
      WHERE environments.user_id is NULL AND subquery.environment_id = environments.id;
    SQL
  end

  def down
    # no-op
  end
end
