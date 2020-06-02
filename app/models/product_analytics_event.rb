# frozen_string_literal: true

# You can find development seeds for this model
# in db/fixtures/development/27_product_analytics_events.rb
class ProductAnalyticsEvent < ApplicationRecord
  # Product analytic records are put in database by collector
  # so there is no default Rails timestamps in the table
  scope :order_by_time, -> { order(collector_tstamp: :desc) }

  # Currently app_id represents project id. For now we use the scope
  # instead of ActiveRecord association. Once the database structure
  # is established we can refactor it.
  scope :by_project, ->(project_id) { where(app_id: project_id.to_s) }

  scope :timerange, ->(duration) {
    where('collector_tstamp BETWEEN ? AND ? ',
          Time.zone.today - duration + 1,
          Time.zone.today + 1)
  }

  class << self
    def count_by_graph(graph, days)
      group(graph).timerange(days).count
    end

    def count_by_day_and_graph(graph, days)
      group("DATE_TRUNC('day', #{graph})").timerange(days).count
    end
  end
end
