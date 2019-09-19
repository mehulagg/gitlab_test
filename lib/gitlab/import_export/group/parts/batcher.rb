# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      module Parts
        class Batcher
          BATCH_SIZE = 2

          def initialize(export_id)
            @export = ::GroupExport.find(export_id)
          end

          def process_next_batch
            batch.on(:success, completion_callback, completion_params)
            batch.jobs do
              next_batch.each do |part|
                part.schedule!
              rescue => e
                part.fail_op(error: e.message)
              end
            end
          end

          def remaining_parts
            @parts ||= export.parts.created
          end

          private

          attr_reader :export

          def batch
            @batch ||= Sidekiq::Batch.new
          end

          def next_batch
            remaining_parts.first(BATCH_SIZE)
          end

          def completion_callback
            Gitlab::ImportExport::Group::Parts::BatchExportComplete
          end

          def completion_params
            { export_id: export.id }
          end
        end
      end
    end
  end
end
