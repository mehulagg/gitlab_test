# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        # This class represents artifact definitions.
        # See doc/development/cicd/job_artifacts.md for more information.
        class Definitions
          FILE_TYPES = {
            archive: 1,
            metadata: 2,
            trace: 3,
            junit: 4,
            sast: 5, ## EE-specific
            dependency_scanning: 6, ## EE-specific
            container_scanning: 7, ## EE-specific
            dast: 8, ## EE-specific
            codequality: 9, ## EE-specific
            license_management: 10, ## EE-specific
            license_scanning: 101, ## EE-specific till 13.0
            performance: 11, ## EE-specific
            metrics: 12, ## EE-specific
            metrics_referee: 13, ## runner referees
            network_referee: 14, ## runner referees
            lsif: 15, # LSIF data for code navigation
            dotenv: 16,
            cobertura: 17,
            terraform: 18, # Transformed json
            accessibility: 19,
            cluster_applications: 20,
            secret_detection: 21, ## EE-specific
            requirements: 22, ## EE-specific
            coverage_fuzzing: 23, ## EE-specific
            browser_performance: 24, ## EE-specific
            load_performance: 25 ## EE-specific
          }.freeze

          FILE_FORMATS = {
            raw: 1,
            zip: 2,
            gzip: 3
          }.freeze

          AVAILABLE_ATTRIBUTES =
            %i[description file_type file_format default_file_name tags options
               file_type_value].freeze

          AVAILABLE_TAGS =
            %i[internal report accessibility coverage security
               container_scanning dast dependency_list test license_scanning
               metrics requirements sast secret_detection terraform
               browser_performance coverage_fuzzing].freeze

          AVAILABLE_OPTIONS = %i[downloadable erasable unsupported].freeze

          class << self
            def find_by_tags(*values)
              all.select { |klass| klass.match_tags?(values) }
            end

            def find_by_options(*values)
              all.select { |klass| klass.match_options?(values) }
            end

            def all
              @all ||= FILE_TYPES.map { |file_type, _| get(file_type) }
            end

            def get(file_type)
              return unless FILE_TYPES[file_type&.to_sym]

              @file_types ||= {}
              @file_types[file_type] ||= "::Gitlab::Ci::Build::Artifacts::Definitions::#{file_type.to_s.camelize}".constantize
            end
          end
        end
      end
    end
  end
end
