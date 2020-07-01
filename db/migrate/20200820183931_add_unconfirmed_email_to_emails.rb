# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddUnconfirmedEmailToEmails < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :emails, :unconfirmed_email, :text # rubocop:disable Migration/AddLimitToTextColumns
  end
end
