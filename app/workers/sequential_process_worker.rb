# frozen_string_literal: true

class SequentialProcessWorker
  include ApplicationWorker

  def perform
    Gitlab::SequentialProcess.new(key_group, 15.minutes, self.class.name, :unsafe_refresh)
                             .execute(merge_request.id)
  end
end
