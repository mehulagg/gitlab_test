# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class Metrics < Base
            self.description =       'The metrics report'
            self.file_type =         :metrics
            self.file_format =       :gzip
            self.default_file_name = 'metrics.txt'
            self.tags =              %i[report metrics]
            self.options =           %i[downloadable erasable]
          end
        end
      end
    end
  end
end
