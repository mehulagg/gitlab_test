# frozen_string_literal: true

module Environments
  class AutoStopCronWorker
    include ApplicationWorker
    include CronjobQueue

    feature_category :continuous_delivery

    def perform
      AutoStopService.new.execute
    end
  end
end
