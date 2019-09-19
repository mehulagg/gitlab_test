# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      module Parts
        class Attributes < Base
          def export_parts
            export.parts.new(export_part_params)
          end

          def import_parts
          end

          def export_part_params
            {
              name: group_part,
              params: {
                group_id:     params[:group_id],
                tmp_dir_path: params[:tmp_dir_path]
              }
            }
          end

          def import_part_params
          end
        end
      end
    end
  end
end
