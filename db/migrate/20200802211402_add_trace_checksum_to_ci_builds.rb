# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddTraceChecksumToCiBuilds < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :ci_builds, :trace_checksum, :string
  end
end
