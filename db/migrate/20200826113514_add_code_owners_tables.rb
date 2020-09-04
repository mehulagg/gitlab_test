# frozen_string_literal: true

class AddCodeOwnersTables < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless table_exists?(:code_owners_files)
      with_lock_retries do
        create_table :code_owners_files do |t|
          t.references :protected_branch, null: false, foreign_key: { on_delete: :cascade }
          t.datetime_with_timezone :updated_at, null: false
          t.text :path, null: false
        end
      end
    end

    add_text_limit :code_owners_files, :path, 1024

    unless table_exists?(:code_owners_sections)
      with_lock_retries do
        create_table :code_owners_sections do |t|
          t.references :file, null: false, foreign_key: { on_delete: :cascade, to_table: :code_owners_files }
          t.boolean :optional, null: false, default: false
          t.text :name, null: false
        end
      end
    end

    add_text_limit :code_owners_sections, :name, 1024

    unless table_exists?(:code_owners_entries)
      with_lock_retries do
        create_table :code_owners_entries do |t|
          t.references :section, null: false, foreign_key: { on_delete: :cascade, to_table: :code_owners_sections }
          t.text :pattern, null: false
          t.text :owners, null: false
        end
      end
    end

    add_text_limit :code_owners_entries, :pattern, 1024
    add_text_limit :code_owners_entries, :owners, 4096
  end

  def down
    if table_exists?(:code_owners_entries)
      with_lock_retries do
        drop_table :code_owners_entries
      end
    end

    if table_exists?(:code_owners_sections)
      with_lock_retries do
        drop_table :code_owners_sections
      end
    end

    if table_exists?(:code_owners_files)
      with_lock_retries do
        drop_table :code_owners_files
      end
    end
  end
end
