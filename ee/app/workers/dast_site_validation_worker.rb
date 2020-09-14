# frozen_string_literal: true

class DastSiteValidationWorker
  include ApplicationWorker

  TokenNotFound = Class.new(StandardError)

  idempotent!

  sidekiq_options retry: 3, dead: false

  sidekiq_retry_in { 25 }

  sidekiq_retries_exhausted do |job|
    dast_site_validation = DastSiteValidation.find(job['args'][0])
    dast_site_validation.update_column(:validation_failed_at, Time.now.utc)
  end

  def perform(dast_site_validation_id)
    dast_site_validation = DastSiteValidation.find(dast_site_validation_id)
    project = dast_site_validation.project

    # permission check
    unless allowed?(project)
      return
    end

    # done check
    if dast_site_validation.validation_passed_at || dast_site_validation.validation_failed_at
      return
    end

    # attempted check
    if dast_site_validation.validation_started_at
      dast_site_validation.update_column(:validation_last_retried_at, Time.now.utc)
    else
      dast_site_validation.update_column(:validation_started_at, Time.now.utc)
    end

    # validation
    uri, _ = Gitlab::UrlBlocker.validate!(dast_site_validation.validation_url)
    response = Gitlab::HTTP.get(uri)

    if Regexp.new(dast_site_validation.dast_site_token.token).match(response.body)
      dast_site_validation.update_column(:validation_passed_at, Time.now.utc)
    else
      raise TokenNotFound.new('could not find token in response body')
    end
  end

  private

  def allowed?(project)
    project.feature_available?(:security_on_demand_scans) &&
      Feature.enabled?(:security_on_demand_scans_site_validation, project)
  end
end
