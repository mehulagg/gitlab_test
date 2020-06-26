# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class ClusterApplications < Base
            self.description =       'The cluster application report'
            self.file_type =         :cluster_applications
            self.file_format =       :gzip
            self.default_file_name = 'gl-cluster-applications.json'
            self.tags =              %i[report]
            self.options =           %i[erasable]
          end
        end
      end
    end
  end
end
