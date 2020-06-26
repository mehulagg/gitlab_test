# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class Lsif < Base
            self.description =       'The code reference artifact file'
            self.file_type =         :lsif
            self.file_format =       :zip
            self.default_file_name = 'lsif.json'
            self.tags =              %i[report]
            self.options =           %i[downloadable erasable]
          end
        end
      end
    end
  end
end
