# frozen_string_literal: true

class AddServicesProjectIdTemplateUniqueConstraint < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    execute <<~SQL
      UPDATE services
        SET template = FALSE WHERE template = TRUE and project_id IS NOT NULL;

      ALTER TABLE services
        ADD CONSTRAINT check_template_or_project CHECK (template = FALSE or project_id IS NULL);
    SQL
  end

  def down
    execute <<~SQL
      ALTER TABLE services
        DROP CONSTRAINT IF EXISTS check_template_or_project
    SQL
  end
end
