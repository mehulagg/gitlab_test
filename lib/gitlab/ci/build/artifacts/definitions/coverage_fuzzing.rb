# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class CoverageFuzzing < Base
            self.description =       'The coverage fuzzing report'
            self.file_type =         :coverage_fuzzing
            self.file_format =       :raw
            self.default_file_name = 'gl-coverage-fuzzing.json'
            self.tags =              %i[security coverage_fuzzing]
            self.options =           %i[erasable]
          end
        end
      end
    end
  end
end
