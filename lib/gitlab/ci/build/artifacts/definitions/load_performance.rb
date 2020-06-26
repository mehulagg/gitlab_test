# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class LoadPerformance < Base
            self.description =       'The Load performance report'
            self.file_type =         :load_performance
            self.file_format =       :raw
            self.default_file_name = 'load-performance.json'
            self.tags =              %i[report]
            self.options =           %i[downloadable erasable]
          end
        end
      end
    end
  end
end
