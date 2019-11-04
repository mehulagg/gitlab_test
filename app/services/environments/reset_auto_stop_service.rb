# frozen_string_literal: true

module Environments
  class ResetAutoStopService < ::BaseService
    def execute(environment)
      return error('the environment has already cancelled auto stop') unless environment.auto_stop_at?

      if environment.reset_auto_stop
        success
      else
        error('failed to update the environment')
      end
    end
  end
end
