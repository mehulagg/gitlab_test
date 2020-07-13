# frozen_string_literal: true

class CreatePipelineReportProcessorTable < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless table_exists?(:ci_pipeline_report_processors)
      create_table :ci_pipeline_report_processors do |t|
        t.bigint :pipeline_id, null: false, index: true, foreign_key: { to_table: :ci_pipelines, on_delete: :cascade }
        t.text :coverage_report, null: false
      end
    end

    add_text_limit :ci_pipeline_report_processors, :coverage_report, 255
  end

  def down
    drop_table :ci_pipeline_report_processors
  end
end
