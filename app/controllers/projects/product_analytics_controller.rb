# frozen_string_literal: true

class Projects::ProductAnalyticsController < Projects::ApplicationController
  before_action :authorize_read_product_analytics!
  before_action :set_graph_vars, only: [:activity, :users]
  before_action :javascript_vars, only: [:example, :test]

  def index
    @events = product_analytics_events.order_by_time.page(params[:page])
  end

  def activity
    requested_graphs = %w(collector_tstamp dvce_created_tstamp)

    requested_graphs.each do |graph|
      @graphs << ProductAnalytics::BuildGraphService
        .new(project, current_user, { graph: graph, timerange: @timerange, by_day: true })
        .execute
    end
  end

  def users
    requested_graphs = %w(
      v_collector platform os_timezone br_lang
      doc_charset v_tracker br_cookies br_colordepth
    )

    requested_graphs.each do |graph|
      @graphs << ProductAnalytics::BuildGraphService
        .new(project, current_user, { graph: graph, timerange: @timerange })
        .execute
    end
  end

  def example
  end

  def test
    @event = product_analytics_events.try(:first)
  end

  private

  def product_analytics_events
    ProductAnalyticsEvent.by_project(@project.id)
  end

  def javascript_vars
    @project_id = @project.id.to_s # To set the right AppId
    # Snowplow remembers values like appId and platform between reloads.
    # That is why we have to rename the tracker with a random integer.
    @random = rand(999999)
    @platform = %w(web mob app)[(@random % 3)]
  end

  def set_graph_vars
    @timerange = 30
    @graphs = []
  end
end
