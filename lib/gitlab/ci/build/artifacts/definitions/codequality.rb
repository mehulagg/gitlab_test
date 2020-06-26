# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class Codequality < Base
            self.description =       'The codequality report'
            self.file_type =         :codequality
            self.file_format =       :raw
            self.default_file_name = 'gl-code-quality-report.json'
            self.tags =              %i[report]
            self.options =           %i[downloadable erasable]
          end
        end
      end
    end
  end
end
