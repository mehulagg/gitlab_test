# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class LicenseManagement < Base
            self.description =       'The licence management report (Deprecated in favor of license_scanning)'
            self.file_type =         :license_management
            self.file_format =       :raw
            self.default_file_name = 'gl-license-management-report.json'
            self.tags =              %i[report license_scanning]
            self.options =           %i[downloadable unsupported erasable]
          end
        end
      end
    end
  end
end
