# frozen_string_literal: true

class VulnerabilitiesSummaryPolicy < BasePolicy
  delegate { @subject.vulnerable }
end
