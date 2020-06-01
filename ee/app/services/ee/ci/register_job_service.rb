# frozen_string_literal: true

module EE
  module Ci
    # RegisterJobService EE mixin
    #
    # This module is intended to encapsulate EE-specific service logic
    # and be included in the `RegisterJobService` service
    module RegisterJobService
      extend ActiveSupport::Concern

      def execute(params = {})
        db_all_caught_up = ::Gitlab::Database::LoadBalancing::Sticking.all_caught_up?(:runner, runner.id)

        super.tap do |result|
          # Since we execute this query against replica it might lead to false-positive
          # We might receive the positive response: "hi, we don't have any more builds for you".
          # This might not be true. If our DB replica is not up-to date with when runner event was generated
          # we might still have some CI builds to be picked. Instead we should say to runner:
          # "Hi, we don't have any more builds now,  but not everything is right anyway, so try again".
          # Runner will retry, but again, against replica, and again will check if replication lag did catch-up.
          if !db_all_caught_up && !result.build
            return ::Ci::RegisterJobService::Result.new(nil, false) # rubocop:disable Cop/AvoidReturnFromBlocks
          end
        end
      end
    end
  end
end
