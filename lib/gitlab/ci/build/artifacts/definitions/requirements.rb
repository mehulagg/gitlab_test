# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class Requirements < Base
            self.description =       'The requirements report'
            self.file_type =         :requirements
            self.file_format =       :raw
            self.default_file_name = 'requirements.json'
            self.tags =              %i[report requirements]
            self.options =           %i[downloadable erasable]
          end
        end
      end
    end
  end
end
