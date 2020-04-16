# frozen_string_literal: true

class AccessibilityReportsComparerEntity < Grape::Entity
  expose :added

  expose :new_errors, using: AccessibilityErrorEntity
end
