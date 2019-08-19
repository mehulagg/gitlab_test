class CreateTestModels < ActiveRecord::Migration[5.2]
  def change
    create_table :test_models do |t|
      t.datetime :build_at
      t.datetime_with_timezone :build_tz_at
      t.timestamp :build_ts_at
    end
  end
end
