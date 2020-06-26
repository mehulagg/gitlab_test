# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class BrowserPerformance < Base
            self.description =       'The browser performance report'
            self.file_type =         :browser_performance
            self.file_format =       :raw
            self.default_file_name = 'browser_performance.json'
            self.tags =              %i[report browser_performance]
            self.options =           %i[downloadable erasable]
          end
        end
      end
    end
  end
end
