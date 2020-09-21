# frozen_string_literal: true

module Ci
  class CompareLicenseScanningReportsService < ::Ci::CompareReportsBaseService
    def comparer_class
      Gitlab::Ci::Reports::LicenseScanning::ReportsComparer
    end

    def serializer_class
      LicenseScanningReportsComparerSerializer
    end

    def get_report(pipeline)
      return ::SCA::LicenseCompliance::NULL if pipeline.blank?

      ::SCA::LicenseCompliance.new(pipeline.project, pipeline)
    end

    private

    def key(base_pipeline, head_pipeline)
      super(base_pipeline, head_pipeline) + [project.software_license_policies.cache_key]
    end
  end
end
