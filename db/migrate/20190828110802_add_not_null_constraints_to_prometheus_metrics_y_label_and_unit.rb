class AddNotNullConstraintsToPrometheusMetricsYLabelAndUnit < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def change
    change_column_null(:prometheus_metrics, :y_label, false) # rubocop:disable Migration/PostMigrationMethods
    change_column_null(:prometheus_metrics, :unit, false) # rubocop:disable Migration/PostMigrationMethods
  end
end
