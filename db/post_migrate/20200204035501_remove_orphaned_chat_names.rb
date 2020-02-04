# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class RemoveOrphanedChatNames < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    execute('DELETE FROM chat_names WHERE service_id NOT IN(SELECT id FROM services)')
  end

  def down
    say 'Orphaned user chat names were removed as a part of this migration and are non-recoverable'
  end
end
