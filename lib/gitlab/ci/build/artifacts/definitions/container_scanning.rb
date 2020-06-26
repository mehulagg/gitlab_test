# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class ContainerScanning < Base
            self.description =       'The container scanning test report'
            self.file_type =         :container_scanning
            self.file_format =       :raw
            self.default_file_name = 'gl-container-scanning-report.json'
            self.tags =              %i[report security container_scanning]
            self.options =           %i[downloadable erasable]
          end
        end
      end
    end
  end
end
