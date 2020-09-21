# frozen_string_literal: true

module Security
  class StoreScansGroupService
    include ::Gitlab::ExclusiveLeaseHelpers

    LEASE_TTL = 30.minutes
    LEASE_NAMESPACE = "store_scans_group"

    def self.execute(artifacts)
      new(artifacts).execute
    end

    def initialize(artifacts)
      @artifacts = artifacts
      @known_keys = Set.new
    end

    def execute
      in_lock(lease_key, ttl: LEASE_TTL) do
        sorted_artifacts.reduce(false) do |deduplicate, artifact|
          store_scan_for(artifact, deduplicate)
        end
      end
    end

    private

    attr_reader :artifacts, :known_keys

    def lease_key
      "#{LEASE_NAMESPACE}:#{sorted_artifacts.map(&:id).join('-')}"
    end

    def sorted_artifacts
      @sorted_artifacts ||= artifacts.tap do |list|
        list.sort_by! { |artifact| artifact.job.name }
        list.sort_by! { |artifact| scanner_order_for(artifact) } if dependency_scanning?
      end
    end

    def scanner_order_for(artifact)
      MergeReportsService::ANALYZER_ORDER.fetch(artifact.security_report.primary_scanner.external_id, Float::INFINITY)
    end

    def dependency_scanning?
      artifacts.first.dependency_scanning?
    end

    def store_scan_for(artifact, deduplicate)
      StoreScanService.execute(artifact, known_keys, deduplicate)
    ensure
      artifact.clear_security_report
    end
  end
end
