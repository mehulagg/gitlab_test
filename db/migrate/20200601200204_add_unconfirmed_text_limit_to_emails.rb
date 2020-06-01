# frozen_string_literal: true

class AddUnconfirmedTextLimitToEmails < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  disable_ddl_transaction!

  # Email address limit is 254 per https://www.rfc-editor.org/errata_search.php?eid=1690
  def up
    add_text_limit :emails, :unconfirmed_email, 254
  end

  def down
    remove_text_limit :emails, :unconfirmed_email
  end
end
