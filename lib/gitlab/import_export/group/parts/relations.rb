# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      module Parts
        class Relations < Base
          def export_parts
            relations.each do |relation|
              export.parts.new(export_part_params(relation))
            end
          end

          def import_parts
          end

          def export_part_params(relation)
            {
              name: group_part,
              params: {
                group_id:     params[:group_id],
                user_id:      params[:user_id],
                tmp_dir_path: params[:tmp_dir_path],
                relation:     { include: relation }
              }
            }
          end

          def import_part_params(relation)
          end

          def relations
            reader.group_tree[:include]
          end

          def reader
            @reader ||= Gitlab::ImportExport::Reader.new(shared: @shared, config: params[:config]) # TBD: remove @shared
          end
        end
      end
    end
  end
end
