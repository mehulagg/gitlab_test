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
        StoreScanService.execute(artifact, known_keys, deduplicate)
      end
    end

    private

    attr_reader :artifacts, :known_keys

    def sorted_artifacts
      artifacts.sort_by { |artifact| artifact.job.name }
    end
  end
end
