# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class SecretDetection < Base
            self.description =       'The secret detection test report'
            self.file_type =         :secret_detection
            self.file_format =       :raw
            self.default_file_name = 'gl-secret-detection-report.json'
            self.tags =              %i[report security secret_detection]
            self.options =           %i[downloadable erasable]
          end
        end
      end
    end
  end
end
