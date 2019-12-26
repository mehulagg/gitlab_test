# frozen_string_literal: true

class ImportFailure < ApplicationRecord
  belongs_to :project
  enum retry_status: { not_triggered: 0, failed: 1, success: 2 }

  validates :project, presence: true
end
