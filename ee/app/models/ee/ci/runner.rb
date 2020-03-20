# frozen_string_literal: true

module EE
  module Ci
    module Runner
      def tick_runner_queue
        ::GitlabUtils::Database::LoadBalancing::Sticking.stick(:runner, id)

        super
      end
    end
  end
end
