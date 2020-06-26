# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class Dast < Base
            self.description =       'The DAST test report'
            self.file_type =         :dast
            self.file_format =       :raw
            self.default_file_name = 'gl-dast-report.json'
            self.tags =              %i[report security dast]
            self.options =           %i[downloadable erasable]
          end
        end
      end
    end
  end
end
