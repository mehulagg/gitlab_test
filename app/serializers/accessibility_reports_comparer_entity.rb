# frozen_string_literal: true

class AccessibilityReportsComparerEntity < Grape::Entity
  expose :status

  expose :added

  expose :new_errors, using: AccessibilityErrorEntity
end
