# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class TmpCheckForSuperuser < ActiveRecord::Migration[6.0]
  # Uncomment the following include if you require helper functions:
  # include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false


  class PgUser < ActiveRecord::Base
    self.table_name = 'pg_user'
    self.primary_key = :usename
  end

  def up
    user = PgUser.where('usename = user').first

    puts user.attributes.inspect

    raise 'detected superuser' if user.usesuper
  end

  def down
  end

end
