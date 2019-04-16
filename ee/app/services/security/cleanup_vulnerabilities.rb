# frozen_string_literal: true

module Security
  class CleanupVulnerabilities
    RETENTION_POLICY = 1.year.to_i.freeze

    def initialize
    end

    def execute
      delete_occurrences
      delete_identifiers
      delete_scanners
    end

    private

    def delete_occurrences
      ::Vulnerabilities::OccurrencePipeline.outdated_from(RETENTION_POLICY.seconds.ago).destroy_all
      ::Vulnerabilities::Occurrence.unused.destroy_all
    end

    def delete_identifiers
      ::Vulnerabilities::Identifier.unused.destroy_all
    end

    def delete_scanners
      ::Vulnerabilities::Scanner.unused.destroy_all
    end


  end
end