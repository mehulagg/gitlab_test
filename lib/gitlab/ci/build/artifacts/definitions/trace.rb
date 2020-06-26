# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class Trace < Base
            self.description =       'The archived trace'
            self.file_type =         :trace
            self.file_format =       :raw
            self.default_file_name = nil
            self.tags =              %i[internal]
            self.options =           %i[]
          end
        end
      end
    end
  end
end
