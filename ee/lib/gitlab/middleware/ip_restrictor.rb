# frozen_string_literal: true

module Gitlab
  module Middleware
    class IpRestrictor
      def initialize(app)
        @app = app
      end

      def call(env)
        ::Gitlab::IpAddressState.with(env['action_dispatch.remote_ip'].to_s) do # rubocop: disable CodeReuse/ActiveRecord
          @app.call(env)
        end
      end
    end
  end
end
