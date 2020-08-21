class CreateBulkImports < ActiveRecord::Migration[6.0]
  def change
    create_table :bulk_imports do |t|
      t.belongs_to :group
      t.belongs_to :user
      t.text :source_host, null: false
      t.text :private_token, null: false # TODO: is it okay to store the token like this? Probably not...

      t.timestamps
    end
  end
end
