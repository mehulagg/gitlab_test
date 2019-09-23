class DropCiBuildTraceSectionsId < ActiveRecord::Migration[5.2]
  def up
    remove_column :ci_build_trace_sections, :id
  end

  def down
    # FIXME: How to fix existing data?
    add_column :ci_build_trace_sections, :id, :primary_key
  end
end
