# frozen_string_literal: true

class LicenseScanningReportLicenseEntity < Grape::Entity
  include RequestAwareEntity

  expose :name
  expose :classification do |model|
    {
      approval_status: model&.classification
    }
  end
  expose :dependencies, using: LicenseScanningReportDependencyEntity
  expose :count do |model|
    model&.dependencies&.count
  end
  expose :url
end
