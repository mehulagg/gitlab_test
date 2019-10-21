# frozen_string_literal: true

class AddLastWikiUpdatedAtToProject < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def change
    add_column :projects, :last_wiki_updated_at, :datetime
  end
end
