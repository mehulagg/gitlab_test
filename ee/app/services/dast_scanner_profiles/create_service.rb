# frozen_string_literal: true

module DastScannerProfiles
  class CreateService < BaseService
    def execute(name: nil)
      return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?

      ActiveRecord::Base.transaction do
        dast_scanner_profile = DastScannerProfile.create!(project: project, name: name)
        ServiceResponse.success(payload: dast_scanner_profile)
      end

    rescue ActiveRecord::RecordInvalid => err
      ServiceResponse.error(message: err.record.errors.full_messages)
    rescue => err
      Gitlab::ErrorTracking.track_exception(err)
      ServiceResponse.error(message: 'Internal server error')
    end

    def allowed?
      Ability.allowed?(current_user, :run_ondemand_dast_scan, project)
    end
  end
end
