# frozen_string_literal: true

module Ci
  class ProjectSemaphore < ApplicationRecord
    self.table_name = 'ci_project_semaphores'

    belongs_to :project, inverse_of: :ci_semaphores

    has_many :job_locks, class_name: 'Ci::JobLock', foreign_key: :semaphore_id

    def under_limit?
      job_locks.locking.count < concurrency
    end
  end
end
