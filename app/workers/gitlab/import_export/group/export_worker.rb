# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      class ExportWorker
        include ApplicationWorker
        include ExceptionBacktrace
        include ImportExport::Group::Queue

        def perform(group_id, user_id)
          ExportService.new(group_id, user_id).execute
        end
      end
    end
  end
end
