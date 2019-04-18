# frozen_string_literal: true

module Security
  class CleanupVulnerabilitiesWorker
    include ApplicationWorker
    include CronjobQueue

    def perform
      return if ::Feature.disabled?(:cleanup_vulnerabilities, default_enabled: false)

      ::Security::CleanupVulnerabilities.new.execute
    end
  end
end