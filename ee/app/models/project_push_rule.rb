# frozen_string_literal: true

class ProjectPushRule < ApplicationRecord
  belongs_to :project
  belongs_to :push_rule

  validates :project_id, presence: true, uniqueness: true
  validates :push_rule_id, presence: true, uniqueness: true
end
