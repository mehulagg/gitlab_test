# frozen_string_literal: true

module SeatsMonitoringHelper
  include Gitlab::Utils::StrongMemoize

  def display_overage_warning?
    current_user&.admin? &&
      license_is_over_capacity?
  end

  private

  def license_is_over_capacity?
    return if current_license.nil? || current_license&.trial?

    # TODO: pass historical_max counter corresponding to the current period to #overage
    current_license.overage > 0
  end

  def current_license
    strong_memoize(:current_license) { License.current }
  end
end
