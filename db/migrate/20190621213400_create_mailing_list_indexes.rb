# frozen_string_literal: true

class CreateMailingListIndexes < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  DOWNTIME = false

  def up
    add_column_with_default(:project_features, :mailing_list_access_level, :integer, default: ProjectFeature::ENABLED, allow_null: false, limit: 2)
    add_column_with_default :application_settings, :mailing_list_enabled, :boolean, default: true
  end

  def down
    remove_columns :application_settings, :mailing_list_enabled
    remove_columns :project_features, :mailing_list_access_level
  end
end
