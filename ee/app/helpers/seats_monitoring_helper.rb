# frozen_string_literal: true

module SeatsMonitoringHelper
  include Gitlab::Utils::StrongMemoize

  def display_overage_warning?
    current_user&.admin? &&
      license_is_over_capacity?
  end

  def banner_content
    end_of_conciliation_period = current_license.current_conciliation_period&.last

    return unless end_of_conciliation_period

    one_week_before = end_of_conciliation_period.weeks_ago(1)
    today = Date.today

    if (one_week_before..end_of_conciliation_period).cover?(today)
      # banner_1 content
    elsif today > end_of_conciliation_period
      # banner_2 content
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
