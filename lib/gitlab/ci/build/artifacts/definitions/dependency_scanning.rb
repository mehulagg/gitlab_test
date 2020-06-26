# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class DependencyScanning < Base
            self.description =       'The dependency scanning test report'
            self.file_type =         :dependency_scanning
            self.file_format =       :raw
            self.default_file_name = 'gl-dependency-scanning-report.json'
            self.tags =              %i[report security dependency_list]
            self.options =           %i[downloadable erasable]
          end
        end
      end
    end
  end
end
