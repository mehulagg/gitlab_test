# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      class ExportPartWorker
        include ApplicationWorker
        include ExceptionBacktrace
        include ImportExport::Group::Queue

        def perform(export_id, part_id)
          ExportPartService.new(export_id, part_id).execute
        end
      end
    end
  end
end
