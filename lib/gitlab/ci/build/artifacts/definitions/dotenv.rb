# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class Dotenv < Base
            self.description =       'The dotenv file contains job variables'
            self.file_type =         :dotenv
            self.file_format =       :gzip
            self.default_file_name = '.env'
            self.tags =              %i[report]
            self.options =           %i[downloadable erasable]
          end
        end
      end
    end
  end
end
