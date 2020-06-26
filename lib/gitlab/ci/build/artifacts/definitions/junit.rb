# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class Junit < Base
            self.description =       'The Junit test reports'
            self.file_type =         :junit
            self.file_format =       :gzip
            self.default_file_name = 'junit.xml'
            self.tags =              %i[report test]
            self.options =           %i[downloadable erasable]
          end
        end
      end
    end
  end
end
