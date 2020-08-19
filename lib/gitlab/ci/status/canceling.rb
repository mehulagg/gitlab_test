# frozen_string_literal: true

module Gitlab
  module Ci
    module Status
      class Canceling < Status::Core
        def text
          s_('CiStatusText|canceling')
        end

        def label
          s_('CiStatusLabel|canceling')
        end

        def icon
          'status_canceled'
        end

        def favicon
          'favicon_status_canceled'
        end
      end
    end
  end
end
