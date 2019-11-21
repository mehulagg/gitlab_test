# frozen_string_literal: true

module Gitlab
  module Ci
    module Status
      module Build
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
            subject.job_lock&.blocked? # TODO: Hyper slow
          end
        end
      end
    end
  end
end
