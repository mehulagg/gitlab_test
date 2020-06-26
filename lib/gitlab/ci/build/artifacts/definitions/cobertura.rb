# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class Cobertura < Base
            self.description =       'The coverage report'
            self.file_type =         :cobertura
            self.file_format =       :gzip
            self.default_file_name = 'cobertura-coverage.xml'
            self.tags =              %i[report coverage]
            self.options =           %i[downloadable erasable]
          end
        end
      end
    end
  end
end
