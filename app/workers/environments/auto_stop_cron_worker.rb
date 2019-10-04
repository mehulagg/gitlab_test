# frozen_string_literal: true

module Environments
  class AutoStopCronWorker
    include ApplicationWorker
    include CronjobQueue

    def perform
      AutoStopService.new.execute
    end
  end
end
