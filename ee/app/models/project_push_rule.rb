# frozen_string_literal: true

class ProjectPushRule < ApplicationRecord
  belongs_to :project
  belongs_to :push_rule
end
