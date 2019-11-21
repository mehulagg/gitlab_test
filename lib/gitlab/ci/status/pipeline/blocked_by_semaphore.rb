# frozen_string_literal: true

module Gitlab
  module Ci
    module Status
      module Pipeline
        class BlockedBySemaphore < Status::Extended
          def text
            s_('CiStatusText|blocked by semaphore')
          end

          def label
            s_('CiStatusLabel|blocked by semaphore')
          end

          def icon
            'status_manual'
          end

          def group
            'favicon_status_manual'
          end

          def self.matches?(subject, user)
            subject.builds.any? { |build| build.job_lock&.blocked? } # TODO: Hyper slow. User compond status.
          end
        end
      end
    end
  end
end
