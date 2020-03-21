# frozen_string_literal: true

class ProductAnalyticsEvent < ApplicationRecord
  scope :timerange, ->(duration) { where('collector_tstamp BETWEEN ? AND ? ', Time.zone.today - duration + 1, Time.zone.today + 1) }
  scope :by_time, -> { order('collector_tstamp DESC') } # default scope breaks the group by
  # Seed is in db/fixtures/development/27_product_analytics_events.rb

  def self.get_some(project_id, limit)
    where(["app_id = ?", project_id]).by_time.limit(limit)
  end

  def self.by_day_and_graph(project_id, graph, days)
    where(["app_id = ?", project_id]).group("DATE_TRUNC('day', #{graph})").timerange(days).count
  end

  def self.by_graph(project_id, graph, days)
    where(["app_id = ?", project_id]).group(graph).timerange(days).count
  end

  def self.number(project_id)
    where(["app_id = ?", project_id]).count
  end
end
