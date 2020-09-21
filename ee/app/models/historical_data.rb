# frozen_string_literal: true

class HistoricalData < ApplicationRecord
  validates :date, presence: true

  # HistoricalData.during((Date.today - 1.year)..Date.today).average(:active_user_count)
  scope :during, ->(range) { where(date: range) }
  # HistoricalData.up_until(Date.today - 1.month).average(:active_user_count)
  scope :up_until, ->(date) { where("date <= :date", date: date) }

  class << self
    def track!
      create!(
        date:               Date.today,
        active_user_count:  License.load_license&.current_active_users_count
      )
    end

    # HistoricalData.at(Date.new(2014, 1, 1)).active_user_count
    def at(date)
      find_by(date: date)
    end

    def max_historical_user_count(license: nil, from: nil, to: nil)
      license ||= License.current
      expires_at = license&.expires_at || Date.today
      from ||= expires_at - 1.year
      to   ||= expires_at

      HistoricalData.during(from..to).maximum(:active_user_count) || 0
    end
  end

  def send_email_reminder_if_approaching_user_limit!
    return unless License.current&.active_user_count_threshold_reached?

    recipients = User
      .active
      .admins
      .pluck(:email)
      .to_set

    if License.current.licensee["Email"]
      recipients << License.current.licensee["Email"]
    end

    LicenseMailer.approaching_active_user_count_limit(recipients.to_a)
  end
end
