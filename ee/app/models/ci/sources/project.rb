# frozen_string_literal: true

module Ci
  module Sources
    class Project < ApplicationRecord
      self.table_name = "ci_sources_projects"

      belongs_to :pipeline, class_name: "Ci::Pipeline"
      belongs_to :source_project, class_name: "Project", foreign_key: :source_project_id

      validates :pipeline, presence: true
      validates :source_project, presence: true
    end
  end
end
