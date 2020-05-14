# frozen_string_literal: true

class Projects::ProductAnalyticsController < Projects::ApplicationController
  respond_to :html

  before_action :javascript_vars, only: [:example, :test]

  # routes are defined in project.rb
  # Database is twitten to by https://gitlab.com/gitlab-org/snowplow-go-collector

  def index
    @number_of_events = ProductAnalyticsEvent.number(@project.id.to_s)
    @events = product_analytics_events(100)
  end

  def activity
    @timerange = 30
    @graphs = []

    %w(collector_tstamp dvce_created_tstamp).each do |graph|
      results = ProductAnalyticsEvent.by_day_and_graph(@project.id.to_s, graph.to_sym, @timerange.days)
      @graphs << { id: graph, keys: results.keys, values: results.values }
    end
  end

  def users
    @timerange = 30
    @graphs = []

    %w(v_collector platform os_timezone br_lang doc_charset v_tracker br_cookies br_colordepth).each do |graph|
      results = ProductAnalyticsEvent.by_graph(@project.id.to_s, graph.to_sym, @timerange.days)
      # TODO Consider sanitizing the keys with https://api.rubyonrails.org/classes/ERB/Util.html#method-c-json_escape to prevent XSS
      @graphs << { id: graph, keys: results.keys, values: results.values }
    end
  end

  def example
  end

  def test
    @event = product_analytics_events(1).try(:first)
  end

  private

  def product_analytics_events(limit)
    ProductAnalyticsEvent.get_some(@project.id.to_s, limit)
  end

  def javascript_vars
    @project_id = @project.id.to_s # To set the right AppId
    # Snowplow remembers values like appId and platform between reloads.
    # That is why we have to rename the tracker with a random integer.
    @random = rand(999999)
    @platform = %w(web mob app)[(@random % 3)]
  end
end
