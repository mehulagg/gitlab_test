# frozen_string_literal: true

module Ci
  class JobLock < ApplicationRecord
    self.table_name = 'ci_job_locks'

    belongs_to :ci_semaphore, class_name: 'Ci::ProjectSemaphore',
      foreign_key: :semaphore_id, inverse_of: :job_locks

    belongs_to :job, class_name: 'Ci::Build', inverse_of: :job_lock

    delegate :under_limit?, :unlock_next, to: :ci_semaphore

    state_machine :status, initial: :created do
      event :obtain do
        transition %i[created blocked] => :locking
      end

      event :wait do
        transition created: :blocked
      end

      event :release do
        transition any - [:released] => :released
      end

      before_transition blocked: :locking do |job_lock|
        job_lock.blocked_duration = Time.now - job_lock.updated_at
      end

      before_transition any => :released do |job_lock|
        job_lock.unlock_next(from: job_lock)
      end

      after_transition %i[created blocked] => :locking do |job_lock|
        job_lock.job.enqueue
      end
    end

    enum status: {
      created: 0,
      locking: 1,
      blocked: 2,
      released: 3,
    }

    def try_lock
      under_limit? ? obtain : wait
    end
  end
end
