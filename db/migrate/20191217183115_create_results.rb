# frozen_string_literal: true

class CreateResults < ActiveRecord::Migration[5.2]
  def change
    create_table :ci_results do |t|
      t.string :name
      t.text :result
      t.integer :job_id
      t.text :field1
      t.text :field2
      t.text :field3
      t.text :field4
      t.text :field5
      t.text :field6
      t.text :field7
      t.text :field8
      t.text :field9
      t.text :field10

      t.timestamps
    end
  end
end
