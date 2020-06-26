# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class Terraform < Base
            self.description =       'The terraform state file'
            self.file_type =         :terraform
            self.file_format =       :raw
            self.default_file_name = 'tfplan.json'
            self.tags =              %i[report terraform]
            self.options =           %i[erasable]
          end
        end
      end
    end
  end
end
