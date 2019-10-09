# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      class ExportPartService < BaseService
        def initialize(export_id, part_id)
          @export = GroupExport.find(export_id)
          @part = @export.parts.find(part_id)
        end

        def execute
          part.start!
        rescue => e
          part.fail_op(error: e.message)
        end

        private

        attr_reader :part
      end
    end
  end
end
