# frozen_string_literal: true

module Security
  class StoreScansGroupService
    def self.execute(artifacts)
      new(artifacts).execute
    end

    def initialize(artifacts)
      @artifacts = artifacts
      @known_keys = Set.new
    end

    def execute
      sorted_artifacts.reduce(false) do |deduplicate, artifact|
        store_scan_for(artifact, deduplicate)
      end
    end

    private

    attr_reader :artifacts, :known_keys

    def sorted_artifacts
      artifacts.tap do |list|
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
