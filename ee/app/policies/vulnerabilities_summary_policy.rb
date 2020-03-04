# frozen_string_literal: true

# VulnerabilitiesSummary uses the same permissions as Vulnerability,
# the :read_vulnerability ability defined in ProjectPolicy

class VulnerabilitiesSummaryPolicy < BasePolicy
  delegate { @subject.vulnerable }
end
