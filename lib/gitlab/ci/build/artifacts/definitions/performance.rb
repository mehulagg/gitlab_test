# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class Performance < Base
            self.description =       'The browser performance report (Deprecated in favor of browser_performance)'
            self.file_type =         :performance
            self.file_format =       :raw
            self.default_file_name = 'performance.json'
            self.tags =              %i[report browser_performance]
            self.options =           %i[downloadable erasable]
          end
        end
      end
    end
  end
end
