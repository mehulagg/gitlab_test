class CreateTerraformStates < ActiveRecord::Migration[6.0]
  def change
    create_table :terraform_states do |t|
      t.string :name
      t.text :value
      t.references :project, foreign_key: true

      t.timestamps
    end
    add_index :terraform_states, :name
  end
end
