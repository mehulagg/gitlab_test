# frozen_string_literal: true

module Geo
  module BlobReplicatorStrategy
    extend ActiveSupport::Concern

    include Delay
    include Gitlab::Geo::LogHelpers

    included do
      event :created
    end

    class_methods do
    end

    # Called by Packages::PackageFile on create
    def handle_after_create_commit
      publish(:created, **created_params)

      schedule_checksum_calculation if needs_checksum?
    end

    # Called by Gitlab::Geo::Replicator#consume
    def consume_created_event
      download
    end

    def carrierwave_uploader
      raise NotImplementedError
    end

    def calculate_checksum!
      model_record.calculate_checksum!
      update_verification_state!(checksum: checksum)
    rescue => e
      log_error("Error calculating the checksum", e)
      update_verification_state!(failure: e.message)
    end

    private

    def update_verification_state!(checksum: nil, failure: nil)
      retry_at, retry_count =
        if failure.present?
          calculate_next_retry_attempt
        end

      model_record.update!(
        verification_checksum: checksum,
        last_verification_ran_at: Time.now,
        last_verification_failure: failure,
        retry_at: retry_at,
        retry_count: retry_count
      )
    end

    def calculate_next_retry_attempt
      retry_count = model_record.retry_count.to_i + 1 # rubocop:disable GitlabSecurity/PublicSend
      [next_retry_time(retry_count), retry_count]
    end

    def download
      ::Geo::BlobDownloadService.new(replicator: self).execute
    end

    def schedule_checksum_calculation
      Geo::BlobVerificationPrimaryWorker.perform_async(replicator.replicable_name, model_record.id)
    end

    def created_params
      { model_record_id: model_record.id }
    end

    def needs_checksum?
      model_record.needs_checksum?
    end
  end
end
