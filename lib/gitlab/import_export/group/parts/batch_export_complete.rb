# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      module Parts
        class BatchExportComplete
          def on_complete(status, options)
            # TBD:
            # if any failures in any of the parts
            # abort all remaining parts
            # update errors
            # clean up
            Rails.logger.info 'Failure!' if status.failures != 0
          end

          def on_success(status, options)
            # TBD:
            # if no remaining parts to process
            # archive the export dir
            # move it to a new location with carrierwave (same as for project export)
            # send email
            # clean up tmp dir
            # mark export as complete
            export_id = options['export_id']

            batcher = Gitlab::ImportExport::Group::Parts::Batcher.new(export_id)

            if batcher.remaining_parts.any?
              batcher.process_next_batch
            else
              export = ::GroupExport.find(export_id)
              export.finish!
              # pack it up & mark as complete
            end
          end
        end
      end
    end
  end
end
