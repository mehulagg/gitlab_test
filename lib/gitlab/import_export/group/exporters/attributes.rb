# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      module Exporters
        class Attributes < Base
          def export_part
            File.write(filename, serialized_attributes)
          end

          private

          def serialized_attributes
            group.to_json
          end

          def filename
            export_path << "/#{Gitlab::ImportExport::Group.group_filename}"
          end
        end
      end
    end
  end
end
