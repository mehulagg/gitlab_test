# frozen_string_literal: true

module Types
  class VisibilityLevelsEnum < BaseEnum
    Gitlab::VisibilityLevel.string_options.each do |name, int_value|
      value name.upcase, value: int_value
    end

    # Deprecated:
    Gitlab::VisibilityLevel.string_options.each do |name, int_value|
      value name.downcase, value: int_value, deprecated: { reason: "Use #{name.upcase}", milestone: '13.4' }
    end
  end
end
