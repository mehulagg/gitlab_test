# frozen_string_literal: true

module DastSiteValidations
  class ValidateService < BaseContainerService
    PermissionsError = Class.new(StandardError)
    TokenNotFound = Class.new(StandardError)

    def execute!
      unless allowed?
        mark_failed
        raise PermissionsError.new('Insufficient permissions')
      end

      return if dast_site_validation.done?

      if dast_site_validation.pending?
        mark_started
      else
        mark_retried
      end

      uri, _ = Gitlab::UrlBlocker.validate!(dast_site_validation.validation_url)
      response = Gitlab::HTTP.get(uri)

      if Regexp.new(dast_site_validation.dast_site_token.token).match(response.body)
        mark_passed
      else
        raise TokenNotFound.new('Could not find token in response body')
      end
    end

    private

    def allowed?
      container.feature_available?(:security_on_demand_scans) &&
        Feature.enabled?(:security_on_demand_scans_site_validation, container)
    end

    def dast_site_validation
      @dast_site_validation ||= params.fetch(:dast_site_validation)
    end

    def mark_failed
      dast_site_validation.update_column(:validation_failed_at, Time.now.utc)
    end

    def mark_passed
      dast_site_validation.update_column(:validation_passed_at, Time.now.utc)
    end

    def mark_started
      dast_site_validation.update_column(:validation_started_at, Time.now.utc)
    end

    def mark_retried
      dast_site_validation.update_column(:validation_last_retried_at, Time.now.utc)
    end
  end
end
