# frozen_string_literal: true

class AddDescriptionToRequirements < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  # rubocop:disable Migration/AddLimitToTextColumns
  # limit is added in 20200923071644_add_text_limit_to_requirements_description
  def change
    add_column :requirements, :description, :text
    add_column :requirements, :description_html, :text
  end
  # rubocop:enable Migration/AddLimitToTextColumns
end
