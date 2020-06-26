# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class Metadata < Base
            self.description =       'The metadata for user-defined artifacts'
            self.file_type =         :metadata
            self.file_format =       :gzip
            self.default_file_name = nil
            self.tags =              %i[internal]
            self.options =           %i[erasable]
          end
        end
      end
    end
  end
end
