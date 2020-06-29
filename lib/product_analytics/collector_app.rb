# frozen_string_literal: true

module ProductAnalytics
  class CollectorApp
    def call(env)
      request = Rack::Request.new(env)
      params = request.params

      return not_found unless EventParams.has_required_params?(params)

      event_params = EventParams.parse_event_params(params)

      if ProductAnalyticsEvent.create(event_params)
        ok
      else
        not_found
      end
    end

    def ok
      [200, {}, ['OK']]
    end

    def not_found
      [404, {}, ['']]
    end
  end
end
