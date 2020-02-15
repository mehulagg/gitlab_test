# frozen_string_literal: true

class RemoveReferenceAndMarkdownVersionFromResourceMilestoneEvents < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    remove_column :resource_milestone_events, :reference
    remove_column :resource_milestone_events, :reference_html
    remove_column :resource_milestone_events, :cached_markdown_version
  end

  def down
    add_column :resource_milestone_events, :reference, :text
    add_column :resource_milestone_events, :reference_html, :text
    add_column :resource_milestone_events, :cached_markdown_version, :integer
  end
end
