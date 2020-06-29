# frozen_string_literal: true

module ProductAnalytics
  class BuildGraphService
    def initialize(project, current_user, params)
      @project = project
      @current_user = current_user
      @params = params
    end

    def execute
      graph = @params[:graph].to_sym
      timerange = @params[:timerange].days
      by_day = @params[:by_day].present?

      results =
        if by_day
          product_analytics_events.count_by_day_and_graph(graph, timerange)
        else
          product_analytics_events.count_by_graph(graph, timerange)
        end

      # TODO Consider sanitizing the keys with
      # https://api.rubyonrails.org/classes/ERB/Util.html#method-c-json_escape
      # to prevent XSS
      {
        id: graph,
        keys: results.keys,
        values: results.values
      }
    end

    private

    def product_analytics_events
      @project.product_analytics_events
    end
  end
end
