# frozen_string_literal: true

module LicenseMonitoringHelper
  include Gitlab::Utils::StrongMemoize

  ACTIVE_USER_COUNT_THRESHOLD_LEVELS = [
    { range: (2..15), percentage: false, value: 1 },
    { range: (16..25), percentage: false, value: 2 },
    { range: (26..99), percentage: true, value: 10 },
    { range: (100..999), percentage: true, value: 8 },
    { range: (1000..nil), percentage: true, value: 5 }
  ].freeze

  def show_active_user_count_threshold_banner?
    return if ::Gitlab.com?
    return unless admin_section?
    return if user_dismissed?(UserCalloutsHelper::ACTIVE_USER_COUNT_THRESHOLD)
    return if license_not_available_or_trial?
    return if current_active_users_count > total_user_count

    current_user&.admin? && active_user_count_threshold_reached?
  end

  def license_is_over_capacity?
    return if ::Gitlab.com?
    return if license_not_available_or_trial?

    current_license_overage > 0
  end

  private

  def license_not_available_or_trial?
    current_license.nil? || current_license.trial?
  end

  def active_user_count_threshold_reached?
    return if current_active_users_count <= 1

    active_user_count_threshold[:value] >= if active_user_count_threshold[:percentage]
                                             remaining_user_count.fdiv(current_active_users_count) * 100
                                           else
                                             remaining_user_count
                                           end
  end

  def current_license
    strong_memoize(:current_license) { License.current }
  end

  def current_license_overage
    strong_memoize(:current_license_overage) { current_license.overage_with_historical_max }
  end

  def current_active_users_count
    strong_memoize(:current_active_users_count) { current_license.current_active_users_count }
  end

  def total_user_count
    strong_memoize(:total_user_count) { current_license.restricted_user_count || 0 }
  end

  def remaining_user_count
    strong_memoize(:remaining_user_count) { total_user_count - current_active_users_count }
  end

  def active_user_count_threshold
    strong_memoize(:active_user_count_threshold) do
      ACTIVE_USER_COUNT_THRESHOLD_LEVELS.find do |threshold|
        threshold[:range].include?(total_user_count)
      end
    end
  end
end
