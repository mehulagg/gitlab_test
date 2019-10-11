# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      module Exporters
        class Relations < Base
          def export_part
            File.write(filepath(filename), serialized_relation)

            [filename]
          end

          private

          def serialized_relation
            group.as_json(relation)[relation_name].to_json
          end

          def relation
            params[:relation]
          end

          def relation_name
            params[:relation][:include].keys.join
          end

          def filename
            "#{relation_name}.json"
          end
        end
      end
    end
  end
end
