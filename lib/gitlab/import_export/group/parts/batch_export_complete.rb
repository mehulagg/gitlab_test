# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      module Parts
        class BatchExportComplete
          # on_complete is triggered when one or more Sidekiq jobs in the batch failed
          # and batch is completed
          # not to confuse with `failed` status of the export part
          def on_complete(status, options)
            export = ::GroupExport.find(options['export_id'])

            mark_as_failed(export)
          end

          def on_success(status, options)
            export = ::GroupExport.find(options['export_id'])

            if export.parts.failed.any?
              mark_as_failed(export)

              return
            end

            if export.parts.created.any?
              Gitlab::ImportExport::Group::Parts::Batcher.process_next_batch(export.id)

              return
            end

            export.upload!
          end

          def mark_as_failed(export)
            export.fail_op!(reason: _('One or more export parts failed'))
          end
        end
      end
    end
  end
end
