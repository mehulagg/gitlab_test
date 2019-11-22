# frozen_string_literal: true

class RenameConversationalDevelopmentIndexTable < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    rename_table :conversational_development_index_metrics, :dev_ops_score_metrics
  end
end
