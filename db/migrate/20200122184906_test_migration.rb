class TestMigration < ActiveRecord::Migration[5.2]
  def up
    execute <<~SQL
      CREATE TABLE foo (id serial primary key, name varchar);
    SQL
  end

  def down
    execute <<~SQL
      DROP TABLE foo;
    SQL
  end
end
