# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Seed
        class Build
          class Lock < Seed::Base
            attr_reader :job

            def initialize(job)
              @job = job
            end

            def to_resource
              return unless job.has_lock?

              semaphore = find_or_create_semaphore

              unless semaphore
                # TODO: Gitlab::Sentry.track_exception or invalid parameters
                raise ArgumentError
                return
              end

              semaphore.job_locks.build(job: job)
            end

            private

            def find_or_create_semaphore
              # TODO: Gitlab::OptimisticLocking to avoid race condition
              ::Ci::ProjectSemaphore.find_or_create_by(attributes_for_semaphore)
            end

            def attributes_for_semaphore
              {
                project: job.project,
                key: job.expanded_lock_key
              }
            end
          end
        end
      end
    end
  end
end
