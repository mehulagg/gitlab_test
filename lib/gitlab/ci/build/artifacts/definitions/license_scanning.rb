# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class LicenseScanning < Base
            self.description =       'The license scanning report'
            self.file_type =         :license_scanning
            self.file_format =       :raw
            self.default_file_name = 'gl-license-scanning-report.json'
            self.tags =              %i[report license_scanning]
            self.options =           %i[downloadable erasable]
          end
        end
      end
    end
  end
end
