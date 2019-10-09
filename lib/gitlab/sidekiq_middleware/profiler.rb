# frozen_string_literal: true

module Gitlab
  module SidekiqMiddleware
    class Profiler
      def call(worker, job, queue)
        if sidekiq_profile?(worker, job)
          yield_with_profiling { yield }
        else
          yield
        end
      end

      private

      def sidekiq_profile?(worker, job)
        p "W" * 100
        p worker.class
        p worker
        p worker.sidekiq_options_hash
        p worker.sidekiq_options_hash.fetch('profile', 'not_found_profile_key')
        p worker.sidekiq_options_hash.fetch('test_profile', 'not_found_test_profile_key')

        worker.class == worker.sidekiq_options_hash.fetch('profile', 'not_found_profile_key')
      end

      def yield_with_profiling
        p "X" * 50
        p "yield_with_profiling"
        yield # {todo} run with profiling
      end
    end
  end
end
