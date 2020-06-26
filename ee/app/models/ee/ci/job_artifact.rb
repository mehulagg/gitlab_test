# frozen_string_literal: true

module EE
  # CI::JobArtifact EE mixin
  #
  # This module is intended to encapsulate EE-specific model logic
  # and be prepended in the `Ci::JobArtifact` model
  module Ci::JobArtifact
    extend ActiveSupport::Concern

    prepended do
      after_destroy :log_geo_deleted_event

      LICENSE_SCANNING_REPORT_FILE_TYPES = %w[license_management license_scanning].freeze
      BROWSER_PERFORMANCE_REPORT_FILE_TYPES = %w[browser_performance performance].freeze

      scope :project_id_in, ->(ids) { where(project_id: ids) }
      scope :with_files_stored_remotely, -> { where(file_store: ::JobArtifactUploader::Store::REMOTE) }

      scope :security_reports, -> do
        with_defined_tags(:report, :security)
      end

      scope :license_scanning_reports, -> do
        with_defined_tags(:report, :license_scanning)
      end

      scope :dependency_list_reports, -> do
        with_defined_tags(:report, :dependency_list)
      end

      scope :container_scanning_reports, -> do
        with_defined_tags(:report, :container_scanning)
      end

      scope :sast_reports, -> do
        with_defined_tags(:report, :sast)
      end

      scope :secret_detection_reports, -> do
        with_defined_tags(:report, :secret_detection)
      end

      scope :dast_reports, -> do
        with_defined_tags(:report, :dast)
      end

      scope :metrics_reports, -> do
        with_defined_tags(:report, :metrics)
      end

      scope :coverage_fuzzing_reports, -> do
        with_defined_tags(:report, :coverage_fuzzing)
      end
    end

    class_methods do
      extend ::Gitlab::Utils::Override

      override :associated_file_types_for
      def associated_file_types_for(file_type)
        return LICENSE_SCANNING_REPORT_FILE_TYPES if LICENSE_SCANNING_REPORT_FILE_TYPES.include?(file_type)
        return BROWSER_PERFORMANCE_REPORT_FILE_TYPES if BROWSER_PERFORMANCE_REPORT_FILE_TYPES.include?(file_type)

        super
      end
    end

    def log_geo_deleted_event
      ::Geo::JobArtifactDeletedEventStore.new(self).create!
    end
  end
end
