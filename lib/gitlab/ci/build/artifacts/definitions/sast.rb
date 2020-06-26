# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class Sast < Base
            self.description =       'The SAST report'
            self.file_type =         :sast
            self.file_format =       :raw
            self.default_file_name = 'gl-sast-report.json'
            self.tags =              %i[report security sast]
            self.options =           %i[downloadable erasable]
          end
        end
      end
    end
  end
end
