# frozen_string_literal: true

class CreateCiBuildReportResultsTable < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    create_table :ci_build_report_results do |t|
      t.references :build, null: false, index: false, foreign_key: { to_table: :ci_builds, on_delete: :cascade }
      t.integer :file_type, limit: 2
      t.integer :report_param, limit: 2
      t.bigint :value
    end

    add_index :ci_build_report_results, [:build_id, :file_type, :report_param],
      unique: true, name: "index_ci_build_report_results_on_build_and_file_type_and_report"
  end
end
