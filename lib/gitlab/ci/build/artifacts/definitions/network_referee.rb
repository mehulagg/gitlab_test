# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class NetworkReferee < Base
            self.description =       'The network referee report'
            self.file_type =         :network_referee
            self.file_format =       :gzip
            self.default_file_name = nil
            self.tags =              %i[report]
            self.options =           %i[erasable]
          end
        end
      end
    end
  end
end
