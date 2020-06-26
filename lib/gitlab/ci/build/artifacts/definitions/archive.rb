# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class Archive < Base
            self.description =       'The user-defined artifacts'
            self.file_type =         :archive
            self.file_format =       :zip
            self.default_file_name = nil
            self.tags =              %i[internal]
            self.options =           %i[downloadable erasable]
          end
        end
      end
    end
  end
end
