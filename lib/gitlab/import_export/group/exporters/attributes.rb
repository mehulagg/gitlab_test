# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      module Exporters
        class Attributes < Base
          def export_part
            File.write(filepath(filename), serialized_attributes)

            [filename]
          end

          private

          def serialized_attributes
            group.to_json
          end

          def filename
            Gitlab::ImportExport::Group.group_filename
          end
        end
      end
    end
  end
end
