class CreateLabs < ActiveRecord::Migration[6.0]
  def change
    create_table :labs do |t|
      t.references :group, null: false, foreign_key: { to_table: :namespaces, on_delete: :cascade }
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
