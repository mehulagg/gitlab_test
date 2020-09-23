# frozen_string_literal: true

class LicenseScanningReportLicenseEntity < Grape::Entity
  include RequestAwareEntity

  expose :name
  expose(:classification) { |model| { approval_status: model&.approval_status } }
  expose :dependencies, using: LicenseScanningReportDependencyEntity
  expose(:count) { |model| model&.dependencies&.count }
  expose :url
end
