# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class Accessibility < Base
            self.description =       'The report artifacts for accesibility testing'
            self.file_type =         :accessibility
            self.file_format =       :raw
            self.default_file_name = 'gl-accessibility.json'
            self.tags =              %i[report accessibility]
            self.options =           %i[downloadable erasable]
          end
        end
      end
    end
  end
end
