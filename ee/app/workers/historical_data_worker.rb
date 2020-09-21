# frozen_string_literal: true

class HistoricalDataWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  # rubocop:disable Scalability/CronWorkerContext
  # This worker does not perform work scoped to a context
  include CronjobQueue
  # rubocop:enable Scalability/CronWorkerContext

  feature_category :billing

  def perform
    return if License.current.nil? || License.current.trial?

    historical_data = HistoricalData.track!
    historical_data.send_email_reminder_if_approaching_user_limit!
  end
end
