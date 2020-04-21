# frozen_string_literal: true

module SeatsMonitoringHelper
  include Gitlab::Utils::StrongMemoize

  def display_license_overage_warning?
    current_user&.admin? &&
      license_is_over_capacity?
  end

  def license_overage_banner
    end_of_conciliation_period = current_license.current_conciliation_period&.last

    if (one_week_before..end_of_conciliation_period).cover?(today)
      render('layouts/header/ee_license_overage_banner.html.haml', conciliation_date: end_of_conciliation_period)
    elsif today > end_of_conciliation_period # Check previous period
      render('layouts/header/ee_license_overage_alert.html.haml')
    end
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
